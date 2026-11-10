<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Produit</title>
    <style>
        .erreur { color: red; font-size: 0.9em; display: block; }
        label { display: block; margin-top: 10px; }
    </style>
</head>
<body>
    <h1>
        <c:choose>
            <c:when test="${empty produit.id}">Nouveau produit</c:when>
            <c:otherwise>Modifier le produit</c:otherwise>
        </c:choose>
    </h1>

    <form method="post" action="${ctx}/produits">
        <c:if test="${not empty produit.id}">
            <input type="hidden" name="id" value="${produit.id}">
        </c:if>

        <label for="nom">Nom *</label>
        <input type="text" id="nom" name="nom" value="${fn:escapeXml(produit.nom)}">
        <c:if test="${not empty erreurs.nom}">
            <span class="erreur"><c:out value="${erreurs.nom}"/></span>
        </c:if>

        <label for="description">Description</label>
        <textarea id="description" name="description" rows="3" cols="40">${fn:escapeXml(produit.description)}</textarea>
        <c:if test="${not empty erreurs.description}">
            <span class="erreur"><c:out value="${erreurs.description}"/></span>
        </c:if>

        <label for="prix">Prix (DH) *</label>
        <input type="text" id="prix" name="prix" value="${fn:escapeXml(not empty param.prix ? param.prix : produit.prix)}">
        <c:if test="${not empty erreurs.prix}">
            <span class="erreur"><c:out value="${erreurs.prix}"/></span>
        </c:if>

        <label for="stock">Stock</label>
        <input type="text" id="stock" name="stock" value="${fn:escapeXml(not empty param.stock ? param.stock : produit.stock)}">
        <c:if test="${not empty erreurs.stock}">
            <span class="erreur"><c:out value="${erreurs.stock}"/></span>
        </c:if>

        <p>
            <button type="submit">Enregistrer</button>
            <a href="${ctx}/produits">Annuler</a>
        </p>
    </form>
</body>
</html>