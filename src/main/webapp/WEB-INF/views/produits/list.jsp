<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Produits</title>
    <style>
        table { border-collapse: collapse; }
        th, td { border: 1px solid #ccc; padding: 6px 10px; }
        .flash { background: #e6f4ea; color: #1e6b34; padding: 8px; }
        .rupture { color: red; font-weight: bold; }
        form.inline { display: inline; }
    </style>
</head>
<body>
    <h1>Catalogue de produits</h1>

    <c:if test="${not empty sessionScope.flash}">
        <p class="flash"><c:out value="${sessionScope.flash}"/></p>
        <c:remove var="flash" scope="session"/>
    </c:if>

    <p><a href="${ctx}/produits?action=new">Ajouter un produit</a></p>

    <c:choose>
        <c:when test="${empty produits}">
            <p>Aucun produit.</p>
        </c:when>
        <c:otherwise>
            <table>
                <tr><th>Nom</th><th>Description</th><th>Prix</th><th>Stock</th><th>Actions</th></tr>
                <c:forEach var="p" items="${produits}">
                    <tr>
                        <td><c:out value="${p.nom}"/></td>
                        <td><c:out value="${p.description}"/></td>
                        <td><fmt:formatNumber value="${p.prix}" minFractionDigits="2" maxFractionDigits="2"/> DH</td>
                        <td class="${p.stock == 0 ? 'rupture' : ''}">${p.stock}</td>
                        <td>
                            <a href="${ctx}/produits?action=edit&id=${p.id}">Éditer</a>
                            <form class="inline" method="post" action="${ctx}/produits?action=delete"
                                  onsubmit="return confirm('Supprimer ce produit ?');">
                                <input type="hidden" name="id" value="${p.id}">
                                <button type="submit">Supprimer</button>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
            </table>
        </c:otherwise>
    </c:choose>

    <p><a href="${ctx}/dashboard">Retour au tableau de bord</a></p>
</body>
</html>