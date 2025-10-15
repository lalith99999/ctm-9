package com.ctm.servlet;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.Optional;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.ctm.dao.MatchDao;
import com.ctm.daoimpl.MatchDaoImpl;
import com.ctm.daoimpl.TournamentDaoImpl;
import com.ctm.model.Match;
import com.ctm.model.MatchStatus;
import com.ctm.model.Tournament;

@WebServlet("/updateinnings")
public class UpdateInningsServlet extends HttpServlet {

    private final MatchDao matchDao = new MatchDaoImpl();
    private final TournamentDaoImpl tournamentDao = new TournamentDaoImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession s = req.getSession(false);
        if (s == null || !"admin".equalsIgnoreCase(String.valueOf(s.getAttribute("role")))) {
            resp.sendRedirect("index.jsp");
            return;
        }

        resp.setHeader("Cache-Control", "no-cache,no-store,must-revalidate");
        resp.setHeader("Pragma", "no-cache");
        resp.setDateHeader("Expires", 0);

        String msg = req.getParameter("msg");
        String err = req.getParameter("err");
        if (msg != null) req.setAttribute("msg", msg);
        if (err != null) req.setAttribute("err", err);

        String action = req.getParameter("action");
        if (action == null) action = "tournaments";

        switch (action) {

            // STEP 1️⃣: List all tournaments with count of live matches
            case "tournaments":
                List<Map<String, Object>> tournaments = matchDao.liveTournamentCounts();
                req.setAttribute("tournaments", tournaments);
                req.setAttribute("mode", "tournaments");
                req.getRequestDispatcher("admin_update_innings.jsp").forward(req, resp);
                return;

            // STEP 2️⃣: Show all matches for a selected tournament
            case "matches":
                long tid = parseLong(req.getParameter("tid"));
                Optional<Tournament> tourOpt = tournamentDao.findTournament(tid);
                if (tourOpt.isEmpty()) {
                    resp.sendRedirect("updateinnings?action=tournaments&err=" + URLEncoder.encode("Tournament not found", StandardCharsets.UTF_8));
                    return;
                }

                List<Match> matches = matchDao.getMatchesByTournament(tid);
                req.setAttribute("mode", "matches");
                req.setAttribute("tournament", tourOpt.get());
                req.setAttribute("matches", matches);
                req.getRequestDispatcher("admin_update_innings.jsp").forward(req, resp);
                return;

            // STEP 3️⃣: Show innings update form for selected match
            case "form":
                long matchId = parseLong(req.getParameter("matchId"));
                Optional<Match> matchOpt = matchDao.findMatch(matchId);
                if (matchOpt.isEmpty()) {
                    resp.sendRedirect("updateinnings?action=tournaments&err=" + URLEncoder.encode("Match not found", StandardCharsets.UTF_8));
                    return;
                }

                Match match = matchOpt.get();
                if (match.getFirstInningsTeamId() == null) {
                    resp.sendRedirect("updateinnings?action=matches&tid=" + match.getTournamentId() + "&err=" +
                            URLEncoder.encode("Match has not started yet", StandardCharsets.UTF_8));
                    return;
                }

                populateScoreboardState(req, match);
                req.setAttribute("mode", "form");
                req.setAttribute("match", match);
                req.getRequestDispatcher("admin_update_innings.jsp").forward(req, resp);
                return;

            default:
                resp.sendRedirect("updateinnings?action=tournaments");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession s = req.getSession(false);
        if (s == null || !"admin".equalsIgnoreCase(String.valueOf(s.getAttribute("role")))) {
            resp.sendRedirect("index.jsp");
            return;
        }

        resp.setHeader("Cache-Control", "no-cache,no-store,must-revalidate");
        resp.setHeader("Pragma", "no-cache");
        resp.setDateHeader("Expires", 0);

        String step = req.getParameter("step");
        long matchId = parseLong(req.getParameter("matchId"));
        long tid = parseLong(req.getParameter("tid"));

        try {
            if ("saveFirst".equalsIgnoreCase(step)) {
                int runs = parseInt(req.getParameter("total"));
                int wickets = parseInt(req.getParameter("wickets"));
                double overs = parseDouble(req.getParameter("overs"));
                int extras = parseExtras(req.getParameter("extras"));

                boolean ok = runs >= 0 && wickets >= 0 && overs >= 0 && extras >= 0 &&
                        matchDao.lockFirstInnings(matchId, runs, wickets, overs, extras);
                String key = ok ? "msg" : "err";
                String text = ok ? "First innings locked" : "Unable to lock first innings";
                resp.sendRedirect("updateinnings?action=form&matchId=" + matchId + "&" + key + "=" +
                        URLEncoder.encode(text, StandardCharsets.UTF_8));
                return;

            } else if ("saveSecond".equalsIgnoreCase(step)) {
                int runs = parseInt(req.getParameter("total"));
                int wickets = parseInt(req.getParameter("wickets"));
                double overs = parseDouble(req.getParameter("overs"));
                int extras = parseExtras(req.getParameter("extras"));

                boolean ok = runs >= 0 && wickets >= 0 && overs >= 0 && extras >= 0 &&
                        matchDao.lockSecondInnings(matchId, runs, wickets, overs, extras);
                String key = ok ? "msg" : "err";
                String text = ok ? "Second innings locked" : "Unable to lock second innings";
                resp.sendRedirect("updateinnings?action=form&matchId=" + matchId + "&" + key + "=" +
                        URLEncoder.encode(text, StandardCharsets.UTF_8));
                return;

            } else if ("endMatch".equalsIgnoreCase(step)) {
                boolean ok = matchDao.finalizeMatch(matchId);
                String key = ok ? "msg" : "err";
                String text = ok ? "Match ended successfully" : "Unable to end match";
                String url = ok
                        ? (tid > 0
                            ? "updateinnings?action=matches&tid=" + tid
                            : "updateinnings?action=tournaments")
                        : "updateinnings?action=form&matchId=" + matchId;
                resp.sendRedirect(url + "&" + key + "=" + URLEncoder.encode(text, StandardCharsets.UTF_8));
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect("updateinnings?action=tournaments&err=" + URLEncoder.encode("Unexpected error", StandardCharsets.UTF_8));
        }
    }

    private void populateScoreboardState(HttpServletRequest req, Match match) {
        long firstTeamId = match.getFirstInningsTeamId();
        long secondTeamId = (firstTeamId == match.getTeam1Id()) ? match.getTeam2Id() : match.getTeam1Id();

        boolean firstIsA = firstTeamId == match.getTeam1Id();
        boolean secondIsA = secondTeamId == match.getTeam1Id();

        int firstRuns = firstIsA ? match.getARuns() : match.getBRuns();
        int firstWickets = firstIsA ? match.getAWkts() : match.getBWkts();
        double firstOvers = firstIsA ? match.getAOvers() : match.getBOvers();
        int firstExtras = firstIsA ? match.getAExtras() : match.getBExtras();

        int secondRuns = secondIsA ? match.getARuns() : match.getBRuns();
        int secondWickets = secondIsA ? match.getAWkts() : match.getBWkts();
        double secondOvers = secondIsA ? match.getAOvers() : match.getBOvers();
        int secondExtras = secondIsA ? match.getAExtras() : match.getBExtras();

        boolean firstLocked = firstOvers > 1e-6 || firstWickets == 10 || Math.abs(firstOvers - 20.0) <= 1e-6;
        boolean secondLocked = secondOvers > 1e-6 || secondWickets == 10 || Math.abs(secondOvers - 20.0) <= 1e-6;
        if (match.getStatus() == MatchStatus.FINISHED) {
            secondLocked = true;
        }

        int target = firstLocked ? firstRuns + 1 : 0;

        req.setAttribute("tournamentId", match.getTournamentId());
        req.setAttribute("firstTeamName", firstIsA ? match.getTeam1Name() : match.getTeam2Name());
        req.setAttribute("secondTeamName", secondIsA ? match.getTeam1Name() : match.getTeam2Name());
        req.setAttribute("firstRuns", firstRuns);
        req.setAttribute("firstWickets", firstWickets);
        req.setAttribute("firstOvers", firstOvers);
        req.setAttribute("firstExtras", firstExtras);
        req.setAttribute("secondRuns", secondRuns);
        req.setAttribute("secondWickets", secondWickets);
        req.setAttribute("secondOvers", secondOvers);
        req.setAttribute("secondExtras", secondExtras);
        req.setAttribute("firstLocked", firstLocked);
        req.setAttribute("secondLocked", secondLocked);
        req.setAttribute("target", target);
        req.setAttribute("maxSecondRuns", target > 0 ? target + 5 : 0);
        req.setAttribute("canEnd", firstLocked && secondLocked && match.getStatus() != MatchStatus.FINISHED);
        req.setAttribute("matchFinished", match.getStatus() == MatchStatus.FINISHED);
        req.setAttribute("resultText", match.getResult());
    }

    private long parseLong(String s) {
        try { return Long.parseLong(s); } catch (Exception e) { return 0L; }
    }

    private int parseInt(String s) {
        try { return Integer.parseInt(s); } catch (Exception e) { return -1; }
    }

    private double parseDouble(String s) {
        try { return Double.parseDouble(s); } catch (Exception e) { return -1; }
    }

    private int parseExtras(String value) {
        if (value == null || value.isBlank()) return 0;
        try {
            int extra = Integer.parseInt(value.trim());
            return extra < 0 ? -1 : extra;
        } catch (NumberFormatException e) {
            return -1;
        }
    }
}
