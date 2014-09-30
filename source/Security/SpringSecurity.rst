Spring Security概要
================================================================================

.. only:: html

 .. contents:: 目次
    :local:

Overview
--------------------------------------------------------------------------------

| Spring Securityとは、アプリケーションのセキュリティを担う「認証」、「認可」の2つを
| 主な機能として提供している。
| 認証機能とは、なりすましによる不正アクセスに対抗するため、ユーザを識別する機能である。
| 認可機能とは、認証された（ログイン中の）ユーザの権限に応じて、
| システムのリソースに対するアクセス制御を行う機能である。
| また、HTTPヘッダーを付与する機能を有する。

| Spring Securityの概要図を、以下に示す。

.. figure:: ./images/spring_security_overview.png
   :alt: Spring Security Overview
   :width: 80%
   :align: center

   **Picture - Spring Security Overview**

| Spring Securityは、認証、認可のプロセスを何層にも連なる
| ServletFilter の集まりで実現している。
| また、パスワードハッシュ機能や、JSPの認可タグライブラリなども提供している。

認証
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
| 認証とは、正当性を確認する行為であり、ネットワークやサーバへ接続する際に
| ユーザ名とパスワードの組み合わせを使って、利用ユーザにその権利があるかどうかや、
| その人が利用ユーザ本人であるかどうかを確認することである。
| Spring Securityでの使用方法は、\ :doc:`Authentication`\ を参照されたい。

パスワードハッシュ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
| 平文のパスワードから、ハッシュ関数を用いて計算されたハッシュ値を、元のパスワードと置き換えることである。
| Spring Securityでの使用方法は、\ :doc:`PasswordHashing`\ を参照されたい。

認可
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
| 認可とは、認証された利用者がリソースにアクセスしようとしたとき、
| アクセス制御処理でその利用者がそのリソースの使用を許可されていることを調べることである。
| Spring Securityでの使用方法は、\ :doc:`Authorization`\ を参照されたい。

HTTPヘッダー付与
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
|  \ `IETF <http://tools.ietf.org/>`_\ や\ `OWASP <https://www.owasp.org/>`_\ が定義しているセキュリティに関連するHTTPヘッダーを有効にするため、クライアントに指示するためのものである。

|

.. _howtouse_springsecurity:

How to use
--------------------------------------------------------------------------------

| Spring Securityを使用するために、以下の設定を定義する必要がある。

pom.xmlの設定
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
| Spring Securityを使用する場合、以下のdependencyを、pom.xmlに追加する必要がある。

.. code-block:: xml

    <dependency>
        <groupId>org.terasoluna.gfw</groupId>
        <artifactId>terasoluna-gfw-security-core</artifactId>  <!-- (1) -->
    </dependency>

    <dependency>
        <groupId>org.terasoluna.gfw</groupId>
        <artifactId>terasoluna-gfw-security-web</artifactId>  <!-- (2) -->
    </dependency>

.. tabularcolumns:: |p{0.10\linewidth}|p{0.90\linewidth}|
.. list-table::
   :header-rows: 1
   :widths: 10 90

   * - 項番
     - 説明
   * - | (1)
     - | terasoluna-gfw-security-coreは、webに依存しないため、ドメイン層のプロジェクトから使用する場合は、
       | terasoluna-gfw-security-coreのみをdependencyに追加すること。
   * - | (2)
     - | terasoluan-gfw-webはwebに関連する機能を提供する。terasoluna-gfw-security-coreにも依存しているため、
       | Webプロジェクトは、terasoluna-gfw-security-webのみをdependencyに追加すること。

Web.xmlの設定
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. code-block:: xml
   :emphasize-lines: 5,13-20

    <context-param>
      <param-name>contextConfigLocation</param-name>
      <param-value>  <!-- (1) -->
          classpath*:META-INF/spring/applicationContext.xml
          classpath*:META-INF/spring/spring-security.xml
      </param-value>
    </context-param>
    <listener>
      <listener-class>
        org.springframework.web.context.ContextLoaderListener
      </listener-class>
    </listener>
    <filter>
      <filter-name>springSecurityFilterChain</filter-name>  <!-- (2) -->
      <filter-class>org.springframework.web.filter.DelegatingFilterProxy</filter-class>  <!-- (3) -->
    </filter>
    <filter-mapping>
      <filter-name>springSecurityFilterChain</filter-name>
      <url-pattern>/*</url-pattern>  <!-- (4) -->
    </filter-mapping>

.. tabularcolumns:: |p{0.10\linewidth}|p{0.90\linewidth}|
.. list-table::
   :header-rows: 1
   :widths: 10 90

   * - 項番
     - 説明
   * - | (1)
     - | contextConfigLocationには、applicationContext.xmlに加えて、
       | クラスパスにSpring Security設定ファイルを追加する。本ガイドラインでは、「spring-security.xml」とする。
   * - | (2)
     - | filter-nameには、Spring Securityの内部で使用されるBean名、「springSecurityFilterChain」 で定義すること。
   * - | (3)
     - 各種機能を有効にするための、Spring Securityのフィルタ設定。
   * - | (4)
     - 全てのリクエストに対して設定を有効にする。

spring-security.xmlの設定
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

| web.xmlにおいて指定したパスに、spring-security.xmlを配置する。
| 通常はsrc/main/resources/META-INF/spring/spring-security.xmlに設定する。
| 以下の例は、雛形のみであるため、詳細な説明は、次章以降を参照されたい。

* spring-mvc.xml

  .. code-block:: xml

    <beans xmlns="http://www.springframework.org/schema/beans"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:sec="http://www.springframework.org/schema/security"
        xmlns:context="http://www.springframework.org/schema/context"
        xsi:schemaLocation="http://www.springframework.org/schema/security
            http://www.springframework.org/schema/security/spring-security.xsd
            http://www.springframework.org/schema/beans
            http://www.springframework.org/schema/beans/spring-beans.xsd
            http://www.springframework.org/schema/context
            http://www.springframework.org/schema/context/spring-context.xsd">
        <sec:http  use-expressions="true">  <!-- (1) -->
        <!-- omitted -->
        </sec:http>
    </beans>

  .. tabularcolumns:: |p{0.10\linewidth}|p{0.90\linewidth}|
  .. list-table::
     :header-rows: 1
     :widths: 10 90

     * - 項番
       - 説明
     * - | (1)
       - | use-expressions="true"と記載することで、アクセス属性のSpring EL式を有効することができる。

  \

      .. note::
          use-expressions="true" で有効になるSpring EL式は、以下を参照されたい。

          \ `Expression-Based Access Control <http://static.springsource.org/spring-security/site/docs/3.1.x/reference/el-access.html>`_\

Appendix
--------------------------------------------------------------------------------

HTTPヘッダー付与の設定
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

spring-security.xmlの\ ``<sec:http>``\ 内に\ ``<sec:headers>``\ を定義し、(1)から(5)を設定することで、HTTPレスポンスにセキュリティに関するヘッダを設定に対応して付与することができる。

  .. code-block:: xml

      <sec:http use-expressions="true">
        <!-- omitted -->
        <sec:headers>
          <sec:cache-control />  <!-- (1) -->
          <sec:content-type-options />  <!-- (2) -->
          <sec:hsts />  <!-- (3) -->
          <sec:frame-options />  <!-- (4) -->
          <sec:xss-protection />  <!-- (5) -->
        </sec:headers>
        <!-- omitted -->
      </sec:http>


  .. tabularcolumns:: |p{0.10\linewidth}|p{0.40\linewidth}|p{0.40\linewidth}|p{0.10\linewidth}|
  .. list-table:: Spring Security によるHTTPヘッダー付与
     :header-rows: 1
     :widths: 10 40 40 10

     * - 項番
       - デフォルト付与値
       - 説明
       - 指定可能オプション有無
     * - | (1)
       - | Cache-Control:no-cache, no-store, max-age=0, must-revalidate
       - | クライアントにデータをキャッシュしないように指示する。
       - | 無し
     * - | (2)
       - | X-Content-Type-Options:nosniff
       - | コンテントタイプを無視して、クライアント側がコンテンツ内容により、自動的に処理方法を決めないように指示する。
       - | 無し
     * - | (3)
       - | Strict-Transport-Security:max-age=31536000 ; includeSubDomains
       - | HTTPSでアクセスしたサイトでは、HTTPSの接続を続けるように指示する。（HTTPでのサイトの場合、無視され、ヘッダ項目として付与されない。）
       - | 有り
     * - | (4)
       - | X-Frame-Options:DENY
       - | コンテンツをiframe内部に表示の可否を指示する。
       - | 有り
     * - | (5)
       - | X-XSS-Protection:1; mode=block
       - | XSSフィルター機能を有効にする指示をする。
       - | 有り

|

  .. tabularcolumns:: |p{0.10\linewidth}|p{0.20\linewidth}|p{0.30\linewidth}|p{0.20\linewidth}|p{0.20\linewidth}|
  .. list-table:: 主に使用する可能性のあるオプション
     :header-rows: 1
     :widths: 10 20 30 20 20

     * - 項番
       - オプション
       - 説明
       - 指定例
       - 出力値
     * - | (3)
       - | max-age-seconds
       - | 該当サイトに対してHTTPSのみでアクセスすることを記憶する秒数（デフォルトは365日）
       - | max-age-seconds="1000"
       - | Strict-Transport-Security:max-age=1000 ; includeSubDomains
     * - | (3)
       - | include-subdomains
       - | サブドメインに対しての適用指示。デフォルト : true。falseを指定すると出力されなくなる。
       - | include-subdomains="false"
       - | Strict-Transport-Security:max-age=31536000
     * - | (4)
       - | policy
       - | コンテンツをiframe内部に表示する許可方法を指示する。デフォルト : DENY（フレーム内に表示するのを全面禁止）。SAMEORIGINは同サイト内ページのみフレームに読み込みを許可する。
       - | policy="SAMEORIGIN"
       - | X-Frame-Options:SAMEORIGIN
     * - | (5)
       - | enabled,block
       - | falseを指定して、XSSフィルターを無効にすることが可能となるが、**未指定を推奨する。**
       - | enabled="false" block="false"
       - | X-XSS-Protection:0

.. raw:: latex

   \newpage

