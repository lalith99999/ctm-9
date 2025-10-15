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

            // STEP 2️⃣: Show all live matches for a selected tournament
            case "matches":
                long tid = parseLong(req.getParameter("tid"));
                Optional<Tournament> tourOpt = tournamentDao.findTournament(tid);
                if (!tourOpt.isPresent()) {
                    resp.sendRedirect("updateinnings?action=tournaments&err=" + URLEncoder.encode("Tournament not found", StandardCharsets.UTF_8));
                    return;
                }

                List<Match> liveMatches = matchDao.getLiveMatchesByTournament(tid);
                req.setAttribute("mode", "matches");
                req.setAttribute("tournament", tourOpt.get());
                req.setAttribute("liveMatches", liveMatches);
                req.getRequestDispatcher("admin_update_innings.jsp").forward(req, resp);
                return;

            // STEP 3️⃣: Show innings update form for selected match
            case "form":
                long matchId = parseLong(req.getParameter("matchId"));
                Optional<Match> matchOpt = matchDao.findMatch(matchId);
                if (!matchOpt.isPresent()) {
                    resp.sendRedirect("updateinnings?action=tournaments&err=" + URLEncoder.encode("Match not found", StandardCharsets.UTF_8));
                    return;
                }

                Match match = matchOpt.get();
                req.setAttribute("mode", "form");
                req.setAttribute("selectedMatchId", match.getMatchId());
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

        try {
            if ("saveFirst".equalsIgnoreCase(step)) {
                int runs = parseInt(req.getParameter("total"));
                int wickets = parseInt(req.getParameter("wickets"));
                double overs = parseDouble(req.getParameter("overs"));
                int extras = 0;

                boolean ok = matchDao.lockFirstInnings(matchId, 0, runs, wickets, overs, extras);
                String msg = ok ? "First innings saved" : "Failed to save first innings";
                resp.sendRedirect("updateinnings?action=form&matchId=" + matchId + "&msg=" + URLEncoder.encode(msg, StandardCharsets.UTF_8));
                return;

            } else if ("saveSecond".equalsIgnoreCase(step)) {
                int runs = parseInt(req.getParameter("total"));
                int wickets = parseInt(req.getParameter("wickets"));
                double overs = parseDouble(req.getParameter("overs"));
                int extras = 0;

                boolean ok = matchDao.lockSecondInnings(matchId, runs, wickets, overs, extras);
                String msg = ok ? "Match completed" : "Failed to lock second innings";
                resp.sendRedirect("updateinnings?action=matches&tid=" + req.getParameter("tid") +
                        "&msg=" + URLEncoder.encode(msg, StandardCharsets.UTF_8));
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect("updateinnings?action=tournaments&err=" + URLEncoder.encode("Unexpected error", StandardCharsets.UTF_8));
        }
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
}
