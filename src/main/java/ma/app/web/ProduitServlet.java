package ma.app.web;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import ma.app.model.Produit;
import ma.app.model.ProduitDAO;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/produits")
public class ProduitServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final String LIST_VIEW = "/WEB-INF/views/produits/list.jsp";
    private static final String FORM_VIEW = "/WEB-INF/views/produits/form.jsp";

    private ProduitDAO dao;

    @Override
    public void init() {
        dao = (ProduitDAO) getServletContext().getAttribute("produitDAO");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");

        if (action == null) {
            req.setAttribute("produits", dao.findAll());
            req.getRequestDispatcher(LIST_VIEW).forward(req, resp);
            return;
        }

        switch (action) {
            case "new" -> {
                req.setAttribute("produit", new Produit());
                req.getRequestDispatcher(FORM_VIEW).forward(req, resp);
            }
            case "edit" -> {
                Produit produit = dao.findById(parse_id(req.getParameter("id")));
                if (produit == null) {
                    resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                    return;
                }
                req.setAttribute("produit", produit);
                req.getRequestDispatcher(FORM_VIEW).forward(req, resp);
            }
            default -> resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String list_url = req.getContextPath() + "/produits";

        if ("delete".equals(req.getParameter("action"))) {
            Produit produit = dao.findById(parse_id(req.getParameter("id")));
            if (produit != null) {
                dao.delete(produit.getId());
                req.getSession().setAttribute("flash", "Produit « " + produit.getNom() + " » supprimé.");
            }
            resp.sendRedirect(list_url);
            return;
        }

        String id_str = trim(req.getParameter("id"));
        String nom = trim(req.getParameter("nom"));
        String description = trim(req.getParameter("description"));
        String prix_str = trim(req.getParameter("prix"));
        String stock_str = trim(req.getParameter("stock"));

        Long id = null;
        if (!id_str.isEmpty()) {
            id = parse_id(id_str);
            if (id == null || dao.findById(id) == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
        }

        Map<String, String> erreurs = new HashMap<>();
        Produit produit = new Produit();
        produit.setId(id);
        produit.setNom(nom);
        produit.setDescription(description);

        if (nom.isEmpty()) {
            erreurs.put("nom", "Le nom est obligatoire.");
        } else if (nom.length() < 2 || nom.length() > 50) {
            erreurs.put("nom", "Le nom doit contenir entre 2 et 50 caractères.");
        }

        if (prix_str.isEmpty()) {
            erreurs.put("prix", "Le prix est obligatoire.");
        } else {
            try {
                BigDecimal prix = new BigDecimal(prix_str.replace(',', '.'));
                if (prix.compareTo(BigDecimal.ZERO) <= 0) {
                    erreurs.put("prix", "Le prix doit être strictement positif.");
                } else {
                    produit.setPrix(prix);
                }
            } catch (NumberFormatException e) {
                erreurs.put("prix", "Le prix doit être un nombre décimal.");
            }
        }

        if (stock_str.isEmpty()) {
            produit.setStock(0);
        } else {
            try {
                int stock = Integer.parseInt(stock_str);
                if (stock < 0) {
                    erreurs.put("stock", "Le stock doit être supérieur ou égal à 0.");
                } else {
                    produit.setStock(stock);
                }
            } catch (NumberFormatException e) {
                erreurs.put("stock", "Le stock doit être un nombre entier.");
            }
        }

        if (description.length() > 255) {
            erreurs.put("description", "La description ne doit pas dépasser 255 caractères.");
        }

        if (!erreurs.isEmpty()) {
            req.setAttribute("erreurs", erreurs);
            req.setAttribute("produit", produit);
            req.getRequestDispatcher(FORM_VIEW).forward(req, resp);
            return;
        }

        dao.save(produit);
        req.getSession().setAttribute("flash", "Produit « " + produit.getNom() + " » enregistré.");
        resp.sendRedirect(list_url);
    }

    private Long parse_id(String value) {
        if (value == null) {
            return null;
        }
        try {
            return Long.valueOf(value.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}