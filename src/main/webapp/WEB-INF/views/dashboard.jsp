<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Tableau de bord</title>
</head>
<body>
    <h1>Bienvenue <c:out value="${user}"/></h1>
    <ul>
        <li><a href="${ctx}/produits">Gestion des produits</a></li>
        <li><a href="${ctx}/logout">Se déconnecter</a></li>
    </ul>
</body>
</html>