<%@ page contentType="text/html; charset=UTF-8"%>
<%@ page pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<html>
<head>
<title>Confirm Screen</title>
</head>
<body>
  <h1>Confirm Screen</h1>
  <c:url value="create" var="url" />
  <form:form action="${url}" method="post">
    <input type="submit" name="form" value="Back" />
    <input type="button" value="Back2"
      onclick="javascript:history.back();" />
    <input type="submit" value="Create" />
  </form:form>
</body>
</html>