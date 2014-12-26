Internationalization
================================================================================

.. only:: html

 .. contents:: Table of Contents
    :depth: 3
    :local:

Overview
--------------------------------------------------------------------------------

Internationalization is a process wherein the display of labels and messages in an application is not fixed to a specific language. It supports multiple languages. The language switching can be achieved by specifying a unit called "Locale" expressing language, country and region.

This section explains how to internationalization messages to display on the screen.

In order to internationalization, following correspondences are required.

* Text elements on the screen(code name, messages, labels of GUI components etc.) acquire from external definitions such as properties file. (should not be hard-coding in the source code)
* Provide the mechanism to specify the locale of the clients.

Methods of specifying the locale is follows:

* Using standard request header (specify by browser language settings)
* Saving into the Cookie using request parameter
* Saving into the Session using request parameter


The image of switching locale is as follows:

.. figure:: ./images_Internationalization/i18n_change_image.png
    :alt: locale change image
    :width: 90%


.. note::

    For internationalization of Codelist, refer to :doc:`Codelist`.

.. tip::

    The most commonly known abbreviation of internationalization is i18n.
    Internationalization is abbreviated as i18n because the number of letters between the first "i" and
    the last "n" is 18 i.e. "nternationalizatio".

|

How to use
--------------------------------------------------------------------------------

Settings of messages definition
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If want to internationalize the messages that display on the screen, use the one of following as component(\ ``MessageSource``\ ) for managing messages.

* ``org.springframework.context.support.ResourceBundleMessageSource``
* ``org.springframework.context.support.ReloadableResourceBundleMessageSource``

Here, introduce an example of using the \ ``ResourceBundleMessageSource``\ .

**applicationContext.xml**

.. code-block:: xml

    <bean id="messageSource"
        class="org.springframework.context.support.ResourceBundleMessageSource">
        <property name="basenames">
            <list>
                <value>i18n/application-messages</value>  <!-- (1) -->
            </list>
        </property>
    </bean>

.. tabularcolumns:: |p{0.10\linewidth}|p{0.90\linewidth}|
.. list-table::
    :header-rows: 1
    :widths: 10 90

    * - | Sr. No.
      - | Description
    * - | (1)
      - | Specify \ ``i18n/application-messages``\  as base name of properties file.
        | It is recommended to store message properties file under i18n directory to support internationalization.
        |
        | For MessageSource details and definition methods, refer to :doc:`MessageManagement`.


|

**Example of storing properties files**

.. figure:: ./images_Internationalization/i18n_properties_filepath.png
    :alt: properties filepath
    :width: 50%

Properties file create in accordance with the following rules.

* File name should be defined in \ :file:`application-messages_XX.properties`\  format. (Specify locale in XX portion)
* The messages defined in \ :file:`application-messages.properties`\  should be created in default language.
* **Make sure you create** \ :file:`application-messages.properties`\ . If it does not exist, messages cannot be fetched from \ ``MessageSource``\  and \ ``JspTagException``\  occurs while setting the messages in JSP.

When create a property file in accordance with the above rules, it becomes the following behavior.

* When locale resolved using \ ``LocaleResolver``\  is zh, \ :file:`application-messages_zh.properties`\  is used.
* when locale resolved using \ ``LocaleResolver``\  is ja, \ :file:`application-messages_ja.properties`\  is used.
* When properties file corresponding to locale resolved using \ ``LocaleResolver``\  does not exist, \ :file:`application-messages.properties`\  is used by default. ("_XX" portion does not exist in file name)

.. note::

  In locale determination, locale is verified until properties file of the corresponding locale is found in the following order.

  #. Locale specified from clients
  #. Locale specified in JVM of application server (may not be set in some cases)
  #. Locale specified in OS of application server

  It is frequently misunderstood that when properties file of locale specified from clients does not exist, default properties file is used.
  In actual scenario, locale specified in the application server in subsequent process is verified and even then the properties file of the corresponding locale is not found, default properties file is used.

.. tip::

   For description of message properties file, refer to :doc:`MessageManagement`.

|

Changing locale as per browser settings
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Settings of AcceptHeaderLocaleResolver
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

If switch the locale using browser settings, use the \ ``AcceptHeaderLocaleResolver``\ .

**spring-mvc.xml**

.. code-block:: xml

    <bean id="localeResolver"
        class="org.springframework.web.servlet.i18n.AcceptHeaderLocaleResolver" /> <!-- (1) -->

.. tabularcolumns:: |p{0.10\linewidth}|p{0.90\linewidth}|
.. list-table::
    :header-rows: 1
    :widths: 10 90

    * - | Sr. No.
      - | Description
    * - | (1)
      - | Specify ``org.springframework.web.servlet.i18n.AcceptHeaderLocaleResolver`` in id attribute "localeResolver" of bean tag.
        | If this \ ``LocaleResolver``\  is used, HTTP header "accept-language" is added for each request and locale gets specified.

.. note::

  When \ ``LocaleResolver``\  is not set, ``org.springframework.web.servlet.i18n.AcceptHeaderLocaleResolver`` is used by default; hence \ ``LocaleResolver``\  need not be set.

|

Messages settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

See the example below for message definition.

**application-messages.properties**

.. code-block:: properties

    title.admin.top = Admin Top

**application-messages_ja.properties**

.. code-block:: properties

    title.admin.top = 管理画面 Top

|

JSP implementation
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

See the example below for jsp implements.

**include.jsp(Common jsp file to be included)**

.. code-block:: jsp

  <%@ page session="false"%>
  <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
  <%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
  <%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>  <!-- (1) -->
  <%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
  <%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec"%>
  <%@ taglib uri="http://terasoluna.org/functions" prefix="f"%>
  <%@ taglib uri="http://terasoluna.org/tags" prefix="t"%>

.. tabularcolumns:: |p{0.10\linewidth}|p{0.90\linewidth}|
.. list-table::
    :header-rows: 1
    :widths: 10 90

    * - | Sr. No.
      - | Description
    * - | (1)
      - | When message is to be output in JSP, it is output using Spring tag library; hence custom tag needs to be defined.
        | ``<%@taglib uri="http://www.springframework.org/tags" prefix="spring"%>``  should be defined.

.. note::

  For details on common jsp files to be included, refer to :ref:`view_jsp_include-label`.


|

**JSP file for screen display**

.. code-block:: jsp

  <spring:message code="title.admin.top" />  <!-- (2) -->

.. tabularcolumns:: |p{0.10\linewidth}|p{0.90\linewidth}|
.. list-table::
    :header-rows: 1
    :widths: 10 90

    * - | Sr. No.
      - | Description
    * - | (2)
      - | Output the message using ``<spring:message>``  which is a Spring tag library of JSP.
        | In code attribute, set the key specified in properties.
        | In this example, if locale is ja, "管理画面 Top" is output and for other locales, "Admin Top" is output.

|

Dynamically changing locale depending on screen operations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The method of dynamically changing the locale depending on screen operations etc. is effective in case of selecting a specific language irrespective of user terminal (browser) settings.

Following is an example of changing locale depending on screen operations.

.. figure:: ./images_Internationalization/i18n_change_locale_on_screen.png
    :alt: i18n change locale on screen
    :align: center
    :width: 40%

If user will be selecting the language, it can be implemented using \ ``org.springframework.web.servlet.i18n.LocaleChangeInterceptor``\ .

\ ``LocaleChangeInterceptor``\  saves the locale value specified in request parameter using \ ``org.springframework.web.servlet.LocaleResolver``\ .

Select the implementation class of \ ``LocaleResolver``\  from the following table.

.. tabularcolumns:: |p{0.05\linewidth}|p{0.60\linewidth}|p{0.35\linewidth}|
.. list-table:: **Types of LocaleResolver**
    :header-rows: 1
    :widths: 5 60 35

    * - No
      - Implementation class
      - How to save locale
    * - 1.
      - ``org.springframework.web.servlet.i18n.SessionLocaleResolver``
      - | Save in server(using \ ``HttpSession``\ )
    * - 2.
      - ``org.springframework.web.servlet.i18n.CookieLocaleResolver``
      - | Save in client(using \ ``Cookie``\ )

.. note::

 When \ ``org.springframework.web.servlet.i18n.AcceptHeaderLocaleResolver``\  is used in \ ``LocaleResolver``\ ,
 locale cannot be changed dynamically using \ ``org.springframework.web.servlet.i18n.LocaleChangeInterceptor``\ .

|

Settings of LocaleChangeInterceptor
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

If switch the locale using request parameter, use the \ ``LocaleChangeInterceptor``\ .

**spring-mvc.xml**

.. code-block:: xml

  <mvc:interceptors>
    <mvc:interceptor>
      <mvc:mapping path="/**" />
      <mvc:exclude-mapping path="/resources/**" />
      <mvc:exclude-mapping path="/**/*.html" />
      <bean
        class="org.springframework.web.servlet.i18n.LocaleChangeInterceptor">  <!-- (1) -->
      </bean>
      <!-- omitted -->
    </mvc:interceptor>
  </mvc:interceptors>

.. tabularcolumns:: |p{0.10\linewidth}|p{0.90\linewidth}|
.. list-table::
    :header-rows: 1
    :widths: 10 90

    * - | 項番
      - | 説明
    * - | (1)
      - | Define ``org.springframework.web.servlet.i18n.LocaleChangeInterceptor`` in interceptor of Spring MVC.

.. note::

    **How to change request parameter name to specify locale**

     .. code-block:: xml

        <bean
            class="org.springframework.web.servlet.i18n.LocaleChangeInterceptor">
            <property name="paramName" value="lang"/>  <!-- (2) -->
        </bean>

     .. tabularcolumns:: |p{0.10\linewidth}|p{0.90\linewidth}|
     .. list-table::
        :header-rows: 1
        :widths: 10 90

        * - | Sr. No.
          - | Description
        * - | (2)
          - | In \ ``paramName``\  property, specify request parameter name. In this example, it is "request URL?lang=xx".
            | **When paramName property is omitted, "locale" gets set.** With "request URL?locale=xx", it becomes :ref:`enabled<i18n_set_locale_jsp>`.

|

Settings of SessionLocaleResolver
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

If save the locale into Servers, use the  \ ``SessionLocaleResolver``\ .

**spring-mvc.xml**

.. code-block:: xml

  <bean id="localeResolver" class="org.springframework.web.servlet.i18n.SessionLocaleResolver">  <!-- (1) -->
      <property name="defaultLocale" value="en"/>  <!-- (2) -->
  </bean>

.. tabularcolumns:: |p{0.10\linewidth}|p{0.90\linewidth}|
.. list-table::
    :header-rows: 1
    :widths: 10 90

    * - | Sr. No.
      - | Description
    * - | (1)
      - | Define id attribute of bean tag in "localeResolver" and specify the class wherein ``org.springframework.web.servlet.LocaleResolver`` is implemented.
        | In this example, ``org.springframework.web.servlet.i18n.SessionLocaleResolver`` that stores locale in session is specified.
        | id attribute of bean tag should be set as "localeResolver".
        | By performing these settings, \ ``SessionLocaleResolver``\  will be used at the \ ``LocaleChangeInterceptor``\ .
    * - | (2)
      - | When locale is not specified in request parameter, locale specified in \ ``defaultLocale``\  property is enabled. In this case, the value fetched in \ ``HttpServletRequest#getLocale``\  is considered.

|

Settings of CookieLocaleResolver
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

If save the locale into Clients, use the  \ ``CookieLocaleResolver``\ .

**spring-mvc.xml**

.. code-block:: xml

  <bean id="localeResolver" class="org.springframework.web.servlet.i18n.CookieLocaleResolver">  <!-- (1) -->
        <property name="defaultLocale" value="en"/>  <!-- (2) -->
        <property name="cookieName" value="localeCookie"/>  <!-- (3) -->
  </bean>

.. tabularcolumns:: |p{0.10\linewidth}|p{0.90\linewidth}|
.. list-table::
    :header-rows: 1
    :widths: 10 90

    * - | Sr. No.
      - | Description
    * - | (1)
      - | In id attribute "localeResolver" of bean tag, specify ``org.springframework.web.servlet.i18n.CookieLocaleResolver``.
        | id attribute of bean tag should be set as "localeResolver".
        | By performing these settings, \ ``CookieLocaleResolver``\  will be used at the \ ``LocaleChangeInterceptor``\ .
    * - | (2)
      - | When locale is not specified, locale specified in \ ``defaultLocale``\  property is enabled. In this case, the value fetched in \ ``HttpServletRequest#getLocale``\  is considered.
    * - | (3)
      - | The value specified in \ ``cookieName``\  property is considered cookie name. If not specified, it is considered as \ ``org.springframework.web.servlet.i18n.CookieLocaleResolver.LOCALE``\ . **It is recommended to change the same since use of Spring Framework is explicit.**

|

Messages settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

See the example below for messages settings.

**application-messages.properties**

.. code-block:: properties

    i.xx.yy.0001 = changed locale
    i.xx.yy.0002 = Confirm change of locale at next screen

**application-messages_ja.properties**

.. code-block:: properties

    i.xx.yy.0001 = Localeを変更しました。
    i.xx.yy.0002 = 次の画面でのLocale変更を確認

|

.. _i18n_set_locale_jsp:

JSP implementation
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

See the example below for jsp implements.

**JSP file for screen display**

.. code-block:: jsp

    <a href='${pageContext.request.contextPath}?locale=en'>English</a>  <!-- (1) -->
    <a href='${pageContext.request.contextPath}?locale=ja'>Japanese</a>
    <spring:message code="i.xx.yy.0001" />

.. tabularcolumns:: |p{0.10\linewidth}|p{0.90\linewidth}|
.. list-table::
    :header-rows: 1
    :widths: 10 90

    * - | Sr. No.
      - | Description
    * - | (1)
      - | Submit the request parameter to switch the locale.
        | Request parameter name is specified in \ ``paramName``\  property of \ ``LocaleChangeInterceptor``\ . (In the above example, use the default parameter name)
        | In the above example, it is changed to English locale in English link and to Japanese locale in Japanese link.
        | Hereafter, the selected locale is enabled.
        | As "en" properties file does not exist, English locale is read from properties file by default.

.. tip::

     * Spring tag library should be defined in common jsp files to be included.
     * For details on common jsp files to be included, refer to :ref:`view_jsp_include-label`.

.. raw:: latex

   \newpage

