データベースアクセス（MyBatis3編）
================================================================================

.. only:: html

 .. contents:: 目次
    :local:
    :depth: 3


.. _DataAccessMyBatis3Overview:

Overview
--------------------------------------------------------------------------------

本節では、\ `MyBatis3 <http://mybatis.org>`_\ を使用してデータベースにアクセスする方法について説明する。

本ガイドラインでは、MyBatis3のMapperインタフェースをRepositoryインタフェースとして使用することを前提としている。
Repositoryインタフェースについては、「:ref:`repository-label`」を参照されたい。

| Overviewでは、MyBatis3とMyBatis-Springを使用してデータベースアクセスする際のアーキテクチャについて説明を行う。
| 実際の使用方法については、「:ref:`DataAccessMyBatis3HowToUse`」を参照されたい。

 .. figure:: images_DataAccessMyBatis3/DataAccessMyBatis3Scope.png
    :alt: Scope of description
    :width: 100%
    :align: center

    **Picture - Scope of description**

|

.. _DataAccessMyBatis3OverviewAboutMyBatis3:

MyBatis3について
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
| MyBatis3は、O/R Mapperの一つだが、データベースで管理されているレコードとオブジェクトをマッピングするという考え方ではなく、
 SQLとオブジェクトをマッピングするという考え方で開発されたO/R Mapperである。
| そのため、正規化されていないデータベースへアクセスする場合や、発行するSQLをO/R Mapperに任せずに、
 アプリケーション側で完全に制御したい場合に有効なO/R Mapperである。

本ガイドラインでは、MyBatis3から追加されたMapperインタフェースを使用して、EntityのCRUD操作を行う。
Mapperインタフェースの詳細については、「:ref:`DataAccessMyBatis3AppendixAboutMapperMechanism`」を参照されたい。

本ガイドラインでは、MyBatis3の全ての機能の使用方法について説明を行うわけではないため、
「\ `MyBatis 3 REFERENCE DOCUMENTATION <http://mybatis.github.io/mybatis-3/>`_ \」も合わせて参照して頂きたい。

|

.. _DataAccessMyBatis3OverviewAboutComponentConstitutionOfMyBatis3:

MyBatis3のコンポーネント構成について
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
| MyBatis3の主要なコンポーネント(設定ファイル)について説明する。
| MyBatis3では、設定ファイルの定義に基づき、以下のコンポーネントが互いに連携する事によって、SQLの実行及びO/Rマッピングを実現している。

 .. tabularcolumns:: |p{0.1\linewidth}|p{0.2\linewidth}|p{0.6\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 20 60

    * - 項番
      - コンポーネント/設定ファイル
      - 説明
    * - (1)
      - MyBatis設定ファイル
      - MyBatis3の動作設定を記載するXMLファイル。

        データベースの接続先、マッピングファイルのパス、MyBatisの動作設定などを記載するファイルである。
        Springと連携して使用する場合は、データベースの接続先やマッピングファイルのパスの設定を本設定ファイルに指定する必要がないため、
        MyBatis3のデフォルトの動作を変更又は拡張する際に、設定を行う事になる。
    * - (2)
      - ``SqlSessionFactoryBuilder``
      - MyBatis設定ファイルを読込み、\ ``SqlSessionFactory`` \を生成するためのコンポーネント。

        Springと連携して使用する場合は、アプリケーションのクラスから本コンポーネントを直接扱うことはない。
    * - (3)
      - `SqlSessionFactory`
      - \ ``SqlSession`` \を生成するためのコンポーネント。

        Springと連携して使用する場合は、アプリケーションのクラスから本コンポーネントを直接扱うことはない。
    * - (4)
      - `SqlSession`
      - SQLの発行やトランザクション制御のAPIを提供するコンポーネント。

        MyBatis3を使ってデータベースにアクセスする際に、もっとも重要な役割を果たすコンポーネントである。
        
        Springと連携して使用する場合は、アプリケーションのクラスから本コンポーネントを直接扱うことは、基本的にはない。
    * - (5)
      - Mapperインタフェース
      - マッピングファイルに定義したSQLをタイプセーフに呼び出すためのインタフェース。

        Mapperインターフェースに対する実装クラスは、MyBatis3が自動で生成するため、開発者はインターフェースのみ作成すればよい。
    * - (6)
      - マッピングファイル

      - SQLとO/Rマッピングの設定を記載するXMLファイル。

|

| 以下に、MyBatis3の主要コンポーネントが、どのような流れでデータベースにアクセスしているのかを説明する。
| データベースにアクセスするための処理は、大きく２つにわける事ができる。

* アプリケーションの起動時に行う処理。下記(1)～(3)の処理が、これに該当する。
* クライアントからのリクエスト毎に行う処理。下記(4)～(10)の処理が、これに該当する。

 .. figure:: images_DataAccessMyBatis3/DataAccessMyBatis3RelationshipOfComponents.png
    :alt: Relationship of MyBatis3 components
    :width: 100%
    :align: center

    **Picture - Relationship of MyBatis3 components**

| アプリケーションの起動時に行う処理は、以下の流れで実行する。
| Springと連携時の流れについては、「:ref:`DataAccessMyBatis3OverviewAboutComponentConstitutionOfMyBatisSpring`」を参照されたい。

 .. tabularcolumns:: |p{0.1\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80


    * - 項番
      - 説明
    * - (1)
      - アプリケーションは、\ ``SqlSessionFactoryBuilder`` \ に対して \ ``SqlSessionFactory`` \ の構築を依頼する。
    * - (2)
      - \ ``SqlSessionFactoryBuilder`` \は、 \ ``SqlSessionFactory`` \を生成するためにMyBatis設定ファイルを読込む。
    * - (3)
      - \ ``SqlSessionFactoryBuilder`` \ は、MyBatis設定ファイルの定義に基づき \ ``SqlSessionFactory`` \を生成する。

|

| クライアントからのリクエスト毎に行う処理は、以下の流れで実行する。
| Springと連携時の流れについては、「:ref:`DataAccessMyBatis3OverviewAboutComponentConstitutionOfMyBatisSpring`」を参照されたい。

 .. tabularcolumns:: |p{0.1\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80


    * - 項番
      - 説明
    * - (4)
      - クライアントは、アプリケーションに対して処理を依頼する。
    * - (5)
      - アプリケーションは、 \ ``SqlSessionFactoryBuilder`` \によって構築された \ ``SqlSessionFactory`` \から \ ``SqlSession`` \を取得する。
    * - (6)
      - \ ``SqlSessionFactory`` \は、\ ``SqlSession`` \を生成しアプリケーションに返却する。
    * - (7)
      - アプリケーションは、 \ ``SqlSession`` \からMapperインタフェースの実装オブジェクトを取得する。
    * - (8)
      - アプリケーションは、Mapperインタフェースのメソッドを呼び出す。
      
        Mapperインタフェースの仕組みについては、「:ref:`DataAccessMyBatis3AppendixAboutMapperMechanism`」を参照されたい。
    * - (9)
      - Mapperインタフェースの実装オブジェクトは、 \ ``SqlSession`` \のメソッドを呼び出して、SQLの実行を依頼する。
    * - (10)
      - \ ``SqlSession`` \は、マッピングファイルから実行するSQLを取得し、SQLを実行する。

 .. tip:: **トランザクション制御について**
 
    上記フローには記載していないが、トランザクションのコミット及びロールバックは、
    アプリケーションのコードから\ ``SqlSession`` \のAPIを直接呼び出して行う。
    
    ただし、Springと連携する場合は、Springのトランザクション管理機能がコミット及びロールバックを行うため、
    アプリケーションのクラスから\ ``SqlSession`` \のトランザクションを制御するためのAPIを直接呼び出すことはない。


|

.. _DataAccessMyBatis3OverviewAboutMyBatisSpring:

MyBatis3とSpringの連携について
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

| MyBatis3とSpringを連携させるライブラリとして、MyBatisから\ `MyBatis-Spring <http://mybatis.github.io/spring/>`_ \というライブラリが提供されている。
| このライブラリを使用することで、MyBatis3のコンポーネントをSpringのDIコンテナ上で管理する事ができる。

MyBatis-Springを使用すると、

* MyBatis3のSQLの実行をSpringが管理しているトランザクション内で行う事ができるため、MyBatis3のAPIに依存したトランザクション制御を行う必要がない。

* MyBatis3の例外は、Springが用意している汎用的な例外(\ ``DataAccessException`` \)へ変換されるため、MyBatis3のAPIに依存しない例外処理を実装する事ができる。

* MyBatis3を使用するための初期化処理は、すべてMyBatis-SpringのAPIが行ってくれるため、基本的にはMyBatis3のAPIを直接使用する必要がない。

* スレッドセーフなMapperオブジェクトの生成が行えるため、シングルトンのServiceクラスにMapperオブジェクトを注入する事ができる。

等のメリットがある。
本ガイドラインでは、MyBatis-Springを使用することを前提とする。

本ガイドラインでは、MyBatis-Springの全ての機能の使用方法について説明を行うわけではないため、
「\ `Mybatis-Spring REFERENCE DOCUMENTATION <http://mybatis.github.io/spring/>`_ \」も合わせて参照して頂きたい。

|

.. _DataAccessMyBatis3OverviewAboutComponentConstitutionOfMyBatisSpring:

MyBatis-Springのコンポーネント構成について
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
| MyBatis-Springの主要なコンポーネントについて説明する。
| MyBatis-Springでは、以下のコンポーネントが連携する事によって、MyBatis3とSpringの連携を実現している。

 .. tabularcolumns:: |p{0.1\linewidth}|p{0.2\linewidth}|p{0.6\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 20 60

    * - 項番
      - コンポーネント/設定ファイル
      - 説明
    * - (1)
      - ``SqlSessionFactoryBean``
      - \ ``SqlSessionFactory`` \を構築し、SpringのDIコンテナ上にオブジェクトを格納するためのコンポーネント。

        MyBatis3標準では、MyBatis設定ファイルに定義されている情報を基に\ ``SqlSessionFactory`` \を構築するが、
        \ ``SqlSessionFactoryBean`` \を使用すると、MyBatis設定ファイルがなくても\ ``SqlSessionFactory`` \を構築することができる。
        もちろん、併用することも可能である。
    * - (2)
      - ``MapperFactoryBean``
      - シングルトンのMapperオブジェクトを構築し、SpringのDIコンテナ上にオブジェクトを格納するためのコンポーネント。

        MyBatis3標準の仕組みで生成されるMapperオブジェクトはスレッドセーフではないため、
        スレッド毎にインスタンスを割り当てる必要があった。
        MyBatis-Springのコンポーネントで作成されたMapperオブジェクトは、
        スレッドセーフなMapperオブジェクトを生成する事ができるため、ServiceなどのシングルトンのコンポーネントにDIすることが可能となる。
    * - (3)
      - ``SqlSessionTemplate``
      - \ ``SqlSession`` \インターフェースを実装したシングルトン版の\ ``SqlSession`` \コンポーネント。

        MyBatis3標準の仕組みで生成される\ ``SqlSession`` \オブジェクトはスレッドセーフではないため、
        スレッド毎にインスタンスを割り当てる必要があった。
        MyBatis-Springのコンポーネントで作成された\ ``SqlSession`` \オブジェクトは、
        スレッドセーフな\ ``SqlSession`` \オブジェクトが生成されるため、ServiceなどのシングルトンのコンポーネントにDIすることが可能になる。

        ただし、本ガイドラインでは、\ ``SqlSession`` \を直接扱う事は想定していない。

|

以下に、MyBatis-Springの主要コンポーネントが、どのような流れでデータベースにアクセスしているのかを説明する。
データベースにアクセスするための処理は、大きく２つにわける事ができる。

* アプリケーションの起動時に行う処理。下記(1)～(4)の処理が、これに該当する。
* クライアントからのリクエスト毎に行う処理。下記(5)～(11)の処理が、これに該当する。


 .. figure:: images_DataAccessMyBatis3/DataAccessMyBatisSpringRelationshipOfComponents.png
    :alt: Relationship of MyBatis-Spring components
    :width: 100%
    :align: center

    **Picture - Relationship of MyBatis-Spring components**


アプリケーションの起動時に行う処理は、以下の流れで実行される。

 .. tabularcolumns:: |p{0.1\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80


    * - 項番
      - 説明
    * - (1)
      - \ ``SqlSessionFactoryBean`` \は、\ ``SqlSessionFactoryBuilder`` \に対して \ ``SqlSessionFactory`` \の構築を依頼する。
    * - (2)
      - \ ``SqlSessionFactoryBuilder`` \は、 \ ``SqlSessionFactory`` \を生成するためにMyBatis設定ファイルを読込む。
    * - (3)
      - \ ``SqlSessionFactoryBuilder`` \は、MyBatis設定ファイルの定義に基づき \ ``SqlSessionFactory`` \を生成する。

        生成された\ ``SqlSessionFactory`` \は、SpringのDIコンテナによって管理される。
    * - (4)
      - \ ``MapperFactoryBean`` \は、スレッドセーフな\ ``SqlSession`` \(\ ``SqlSessionTemplate`` \)の生成を行い、
        スレッドセーフなMapperオブジェクト(MapperインタフェースのProxyオブジェクト)の生成する。

        生成されたMapperオブジェクトは、SpringのDIコンテナによって管理され、ServiceクラスなどにDIされる。
        Mapperオブジェクトは、スレッドセーフな\ ``SqlSession`` \(\ ``SqlSessionTemplate`` \)を利用することで、スレッドセーフな実装を提供している。

|

クライアントからのリクエスト毎に行う処理は、以下の流れで実行される。

 .. tabularcolumns:: |p{0.1\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80


    * - 項番
      - 説明
    * - (5)
      - クライアントは、アプリケーションに対して処理を依頼する。
    * - (6)
      - アプリケーション(Service)は、 DIコンテナによって注入されたMapperオブジェクト(Mapperインターフェースを実装したProxyオブジェクト)のメソッドを呼び出す。

        Mapperインタフェースの仕組みについては、 「:ref:`DataAccessMyBatis3AppendixAboutMapperMechanism`」を参照されたい。
    * - (7)
      - Mapperオブジェクトは、呼び出されたメソッドに対応する\ ``SqlSession`` \(\ ``SqlSessionTemplate`` \)のメソッドを呼び出す。
    * - (8)
      - \ ``SqlSession`` \(\ ``SqlSessionTemplate`` \)は、Proxy化されたスレッドセーフな\ ``SqlSession`` \のメソッドを呼び出す。
    * - (9)
      - Proxy化されたスレッドセーフな\ ``SqlSession`` \は、トランザクションに割り当てられているMyBatis3標準の\ ``SqlSession`` \を使用する。

        トランザクションに割り当てられている\ ``SqlSession`` \が存在しない場合は、MyBatis3標準の\ ``SqlSession`` \を取得するために、
        \ ``SqlSessionFactory`` \ のメソッドを呼び出す。
    * - (10)
      - \ ``SqlSessionFactory`` \は、MyBatis3標準の\ ``SqlSession`` \を返却する。

        返却されたMyBatis3標準の\ ``SqlSession`` \はトランザクションに割り当てられるため、同一トランザクション内であれば、新たに生成されることはなく、
        同じ\ ``SqlSession`` \が使用される仕組みになっている。
    * - (11)
      - MyBatis3標準の\ ``SqlSession`` \は、マッピングファイルから実行するSQLを取得し、SQLを実行する。

 .. tip:: **トランザクション制御について**

    上記フローには記載していないが、トランザクションのコミット及びロールバックは、Springのトランザクション管理機能が行う。
    
    Springのトランザクション管理機能を使用したトランザクション管理方法については、
    「:ref:`service_transaction_management`」を参照されたい。

|


.. _DataAccessMyBatis3HowToUse:

How to use
--------------------------------------------------------------------------------

ここからは、実際にMyBatis3を使用して、データベースにアクセスするための設定及び実装方法について、説明する。

以降の説明は、大きく以下に分類する事ができる。


 .. tabularcolumns:: |p{0.1\linewidth}|p{0.20\linewidth}|p{0.60\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 20 60


    * - 項番
      - 分類
      - 説明
    * - (1)
      - アプリケーション全体の設定
      - MyBatis3をアプリケーションで使用するための設定方法や、
        MyBatis3の動作を変更するための設定方法について記載している。

        ここに記載している内容は、\ **プロジェクト立ち上げ時にアプリケーションアーキテクトが設定を行う時に必要となる。**\
        そのため、基本的にはアプリケーション開発者が個々に意識する必要はない部分である。
        
        以下のセクションが、この分類に該当する。
        
        * :ref:`DataAccessMyBatis3HowToUseSettingsPomXml`
        * :ref:`DataAccessMyBatis3HowToUseSettingsCooperateWithMyBatis3AndSpring`
        * :ref:`DataAccessMyBatis3HowToUseSettingsMyBatis3`
        
        MyBatis3用のブランクプロジェクトからプロジェクトを生成した場合は、
        上記で説明している設定の多くが既に設定済みの状態となっているため、アプリケーションアーキテクトは、
        プロジェクト特性を判断し、必要に応じて設定の追加及び変更を行うことになる。

    * - (2)
      - データアクセス処理の実装方法
      - MyBatis3を使った基本的なデータアクセス処理の実装方法について記載している。
      
        ここに記載している内容は、\ **アプリケーション開発者が実装時に必要となる。**\
        
        以下のセクションが、この分類に該当する。
        
        * :ref:`DataAccessMyBatis3HowToDababaseAccess`
        * :ref:`DataAccessMyBatis3HowToUseResultSetMapping`
        * :ref:`DataAccessMyBatis3HowToUseFind`
        * :ref:`DataAccessMyBatis3HowToUseCreate`
        * :ref:`DataAccessMyBatis3HowToUseUpdate`
        * :ref:`DataAccessMyBatis3HowToUseDelete`
        * :ref:`DataAccessMyBatis3HowToUseDynamicSql`
        * :ref:`DataAccessMyBatis3HowToUseLikeEscape`
        * :ref:`DataAccessMyBatis3HowToUseSqlInjectionCountermeasure`

|

.. _DataAccessMyBatis3HowToUseSettingsPomXml:

pom.xmlの設定
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

| インフラストラクチャ層にMyBatis3を使用する場合は、\ :file:`pom.xml`\にterasoluna-gfw-mybatis3への依存関係を追加する。
| マルチプロジェクト構成の場合は、domainプロジェクトの\ :file:`pom.xml`\に追加する。
| MyBatis3用のブランクプロジェクトからプロジェクトを生成した場合は、terasoluna-gfw-mybatis3への依存関係は、設定済の状態である。

 .. code-block:: xml
    :emphasize-lines: 22-26

    <?xml version="1.0" encoding="UTF-8"?>
    <project xmlns="http://maven.apache.org/POM/4.0.0"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
            http://maven.apache.org/maven-v4_0_0.xsd">

        <modelVersion>4.0.0</modelVersion>
        <artifactId>projectName-domain</artifactId>
        <packaging>jar</packaging>

        <parent>
            <groupId>com.example</groupId>
            <artifactId>mybatis3-example-app</artifactId>
            <version>1.0.0-SNAPSHOT</version>
            <relativePath>../pom.xml</relativePath>
        </parent>

        <dependencies>
        
            <!-- omitted -->

            <!-- (1) -->
            <dependency>
                <groupId>org.terasoluna.gfw</groupId>
                <artifactId>terasoluna-gfw-mybatis3</artifactId>
            </dependency>

            <!-- omitted -->

        </dependencies>

        <!-- omitted -->

    </project>

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - terasoluna-gfw-mybatis3をdependenciesに追加する。
        terasoluna-gfw-mybatis3には、MyBatis3及びMyBatis-Springへの依存関係が定義されている。
        
 .. tip:: **terasoluna-gfw-parentをParentプロジェクトとして使用しない場合の設定方法について**
 
    親プロジェクトとしてterasoluna-gfw-parentプロジェクトを指定していない場合は、バージョンの指定も個別に必要となる。

     .. code-block:: xml
        :emphasize-lines: 4
 
        <dependency>
            <groupId>org.terasoluna.gfw</groupId>
            <artifactId>terasoluna-gfw-mybatis3</artifactId>
            <version>1.1.0.RELEASE</version>
        </dependency>
        
    上記例では1.1.0.RELEASEを指定しているが、実際に指定するバージョンは、プロジェクトで利用するバージョンを指定すること。

|

.. _DataAccessMyBatis3HowToUseSettingsCooperateWithMyBatis3AndSpring:

MyBatis3とSpringを連携するための設定
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. _DataAccessMyBatis3HowToUseSettingsDataSource:

データソースの設定
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

| MyBatis3とSpringを連携する場合、データソースはSpringのDIコンテナで管理しているデータソースを使用する必要がある。
| MyBatis3用のブランクプロジェクトからプロジェクトを生成した場合は、Apache Commons DBCPのデータソースが設定済の状態であるため、
 プロジェクトの要件に合わせて設定を変更すること。

データソースの設定方法については、共通編の「\ :ref:`data-access-common_howtouse_datasource` \」を参照されたい。

|

.. _DataAccessMyBatis3HowToUseSettingsTransactionManager:

トランザクション管理の設定
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

| MyBatis3とSpringを連携する場合、
 トランザクション管理はSpringのDIコンテナで管理している\ ``PlatformTransactionManager`` \を使用する必要がある。

| ローカルトランザクションを使用する場合は、JDBCのAPIを呼び出してトランザクション制御を行う\ ``DataSourceTransactionManager`` \を使用する。
| MyBatis3用のブランクプロジェクトからプロジェクトを生成した場合は、\ ``DataSourceTransactionManager`` \が設定済みの状態である。

設定例は以下の通り。

- :file:`[projectName]-env.xml`

 .. code-block:: xml
    :emphasize-lines: 15-20

    <?xml version="1.0" encoding="UTF-8"?>
    <beans xmlns="http://www.springframework.org/schema/beans"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:jee="http://www.springframework.org/schema/jee"
        xmlns:jdbc="http://www.springframework.org/schema/jdbc"
        xsi:schemaLocation="http://www.springframework.org/schema/jdbc
            http://www.springframework.org/schema/jdbc/spring-jdbc.xsd
            http://www.springframework.org/schema/jee
            http://www.springframework.org/schema/jee/spring-jee.xsd
            http://www.springframework.org/schema/beans
            http://www.springframework.org/schema/beans/spring-beans.xsd">

        <!-- omitted -->

        <!-- (1) -->
        <bean id="transactionManager"
            class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
            <!-- (2) -->
            <property name="dataSource" ref="dataSource" />
        </bean>

        <!-- omitted -->

    </beans>


 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - \ ``PlatformTransactionManager`` \として、\ ``org.springframework.jdbc.datasource.DataSourceTransactionManager`` \を指定する。
    * - (2)
      - \ ``dataSource`` \プロパティに、設定済みのデータソースのbeanを指定する。

        トランザクション内でSQLを実行する際は、ここで指定したデータソースからコネクションが取得される。

 .. note:: **PlatformTransactionManagerのbean IDについて**
 
    id属性には、\ ``transactionManager`` \を指定することを推奨する。
    
    \ ``transactionManager`` \以外の値を指定すると、
    \ ``<tx:annotation-driven>`` \タグのtransaction-manager属性に同じ値を設定する必要がある。
    

|

アプリケーションサーバから提供されているトランザクションマネージャを使用する場合は、JTAのAPIを呼び出してトランザクション制御を行う
\ ``org.springframework.transaction.jta.JtaTransactionManager`` \を使用する。

設定例は以下の通り。

- :file:`[projectName]-env.xml`

 .. code-block:: xml
    :emphasize-lines: 6,13-14,18-19

    <?xml version="1.0" encoding="UTF-8"?>
    <beans xmlns="http://www.springframework.org/schema/beans"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:jee="http://www.springframework.org/schema/jee"
        xmlns:jdbc="http://www.springframework.org/schema/jdbc"
        xmlns:tx="http://www.springframework.org/schema/tx"
        xsi:schemaLocation="http://www.springframework.org/schema/jdbc
            http://www.springframework.org/schema/jdbc/spring-jdbc.xsd
            http://www.springframework.org/schema/jee
            http://www.springframework.org/schema/jee/spring-jee.xsd
            http://www.springframework.org/schema/beans
            http://www.springframework.org/schema/beans/spring-beans.xsd
            http://www.springframework.org/schema/tx
            http://www.springframework.org/schema/tx/spring-tx.xsd">

        <!-- omitted -->

        <!-- (1) -->
        <tx:jta-transaction-manager />

        <!-- omitted -->

    </beans>

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - \ ``<tx:jta-transaction-manager />`` \を指定すると、
        アプリケーションサーバに対して最適な \ ``JtaTransactionManager`` \がbean定義される。

|

.. _DataAccessMyBatis3HowToUseSettingsMyBatis-Spring:

MyBatis-Springの設定
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

MyBatis3とSpringを連携する場合、MyBatis-Springのコンポーネントを使用して、

* MyBatis3とSpringを連携するために必要となる処理がカスタマイズされた\ ``SqlSessionFactory``\ の生成
* スレッドセーフなMapperオブジェクト(MapperインタフェースのProxyオブジェクト)の生成

を行う必要がある。

MyBatis3用のブランクプロジェクトからプロジェクトを生成した場合は、MyBatis3とSpringを連携するための設定は、
設定済みの状態である。

設定例は以下の通り。

- :file:`[projectName]-infra.xml`

 .. code-block:: xml
    :emphasize-lines: 4,7-8,12-20,22-23

    <?xml version="1.0" encoding="UTF-8"?>
    <beans xmlns="http://www.springframework.org/schema/beans"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:mybatis="http://mybatis.org/schema/mybatis-spring"
        xsi:schemaLocation="http://www.springframework.org/schema/beans 
            http://www.springframework.org/schema/beans/spring-beans.xsd
            http://mybatis.org/schema/mybatis-spring
            http://mybatis.org/schema/mybatis-spring.xsd">

        <import resource="classpath:/META-INF/spring/projectName-env.xml" />

        <!-- (1) -->
        <bean id="sqlSessionFactory"
            class="org.mybatis.spring.SqlSessionFactoryBean">
            <!-- (2) -->
            <property name="dataSource" ref="dataSource" />
            <!-- (3) -->
            <property name="configLocation"
                value="classpath:/META-INF/mybatis/mybatis-config.xml" />
        </bean>

        <!-- (4) -->
        <mybatis:scan base-package="com.example.domain.repository" />

    </beans>


 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
   :header-rows: 1
   :widths: 10 80

   * - 項番
     - 説明
   * - (1)
     - \ ``SqlSessionFactory`` \を生成するためのコンポーネントとして、\ ``SqlSessionFactoryBean`` \をbean定義する。
   * - (2)
     - \ ``dataSource`` \プロパティに、設定済みのデータソースのbeanを指定する。

       MyBatis3の処理の中でSQLを発行する際は、ここで指定したデータソースからコネクションが取得される。
   * - (3)
     - \ ``configLocation`` \プロパティに、MyBatis設定ファイルのパスを指定する。

       ここで指定したファイルが\ ``SqlSessionFactory`` \を生成する時に読み込まれる。
   * - (4)
     - Mapperインタフェースをスキャンするために\ ``<mybatis:scan>`` \を定義し、\ ``base-package`` \属性には、
       Mapperインタフェースが格納されている基底パッケージを指定する。

       指定されたパッケージ配下に格納されている Mapperインタフェースがスキャンされ、
       スレッドセーフなMapperオブジェクト(MapperインタフェースのProxyオブジェクト)が自動的に生成される。

       **【指定するパッケージは、各プロジェクトで決められたパッケージにすること】**

 .. note:: **MyBatis3の設定方法について**

    \ ``SqlSessionFactoryBean`` \を使用する場合、MyBatis3の設定は、
    MyBatis設定ファイルではなくbeanのプロパティに直接指定することもできるが、
    本ガイドラインでは、MyBatis3自体の設定はMyBatis標準の設定ファイルに指定する方法を推奨する。

|

.. _DataAccessMyBatis3HowToUseSettingsMyBatis3:

MyBatis3の設定
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

| MyBatis3では、MyBatis3の動作をカスタマイズするための仕組みが用意されている。
| MyBatis3の動作をカスタマイズする場合は、MyBatis設定ファイルに設定値を追加する事で実現可能である。

| ここでは、アプリケーションの特性に依存しない設定項目についてのみ、説明を行う。
| その他の設定項目に関しては、
 「\ `MyBatis 3 REFERENCE DOCUMENTATION(Configuration XML) <http://mybatis.github.io/mybatis-3/configuration.html>`_ \」を参照し、
 アプリケーションの特性にあった設定を行うこと。
| 基本的にはデフォルト値のままでも問題ないが、アプリケーションの特性を考慮し、必要に応じて設定を変更すること。

 .. note:: **MyBatis設定ファイルの格納場所について**
 
    本ガイドラインでは、MyBatis設定ファイルは、
    \ :file:`/src/main/resources/META-INF/mybatis/mybatis-config.xml`\ に格納することを推奨している。

    MyBatis3用のブランクプロジェクトからプロジェクトを生成した場合は、上記ファイルは格納済みの状態である。

|

.. _DataAccessMyBatis3HowToUseSettingsTypeAlias:

TypeAliasの設定
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

TypeAliasを使用すると、マッピングファイルで指定するJavaクラスに対して、エイリアス名(短縮名)を割り当てる事ができる。

TypeAliasを使用しない場合、マッピングファイルで指定する\ ``type`` \属性、\ ``parameterType`` \属性、\ ``resultType`` \属性などには、
Javaクラスの完全修飾クラス名(FQCN)を指定する必要があるため、マッピングファイルの記述効率の低下、記述ミスの増加などが懸念される。

| 本ガイドラインでは、記述効率の向上、記述ミスの削減、マッピングファイルの可読性向上などを目的として、TypeAliasを使用することを推奨する。
| MyBatis3用のブランクプロジェクトからプロジェクトを生成した場合は、
 Entityを格納するパッケージ(\ ``${projectPackage}.domain.model``\)配下に格納されるクラスがTypeAliasの対象となっている。
 必要に応じて、設定を追加されたい。

TypeAliasの設定方法は以下の通り。

- :file:`mybatis-config.xml`

 .. code-block:: xml
    :emphasize-lines: 7-8

    <?xml version="1.0" encoding="UTF-8" ?>
    <!DOCTYPE configuration
      PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
      "http://mybatis.org/dtd/mybatis-3-config.dtd">
    <configuration>
        <typeAliases>
            <!-- (1) -->
            <package name="com.example.domain.model" />
        </typeAliases>
    </configuration>

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
   :header-rows: 1
   :widths: 10 80

   * - 項番
     - 説明
   * - (1)
     - \ ``package`` \要素の\ ``name`` \属性に、エイリアスを設定するクラスが格納されているパッケージ名を指定する。
     
       指定したパッケージ配下に格納されているクラスは、パッケージの部分が除去された部分が、エイリアス名となる。
       上記例だと、``com.example.domain.model.Account`` \クラスのエイリアス名は、\ ``Account`` \となる。

       **【指定するパッケージは、各プロジェクトで決められたパッケージにすること】**


 .. tip:: **クラス単位にType Aliasを設定する方法について**
 
    Type Aliasの設定には、クラス単位に設定する方法やエイリアス名を明示的に指定する方法が用意されている。
    詳細は、Appendixの「:ref:`DataAccessMyBatis3AppendixSettingsTypeAlias`」を参照されたい。

|

TypeAliasを使用した際の、マッピングファイルの記述例は以下の通り。

 .. code-block:: xml
    :emphasize-lines: 8,13,19

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">

    <mapper namespace="com.example.domain.repository.account.AccountRepository">

        <resultMap id="accountResultMap"
            type="Account">
            <!-- omitted -->
        </resultMap>

        <select id="findOne"
            parameterType="string"
            resultMap="accountResultMap">
            <!-- omitted -->
        </select>

        <select id="findByCriteria"
            parameterType="AccountSearchCriteria"
            resultMap="accountResultMap">
            <!-- omitted -->
        </select>

    </mapper>

 .. tip:: **MyBatis3標準のエイリアス名について**
 
    プリミティブ型やプリミティブラッパ型などの一般的なJavaクラスについては、予めエイリアス名が設定されている。

    予め設定されるエイリアス名については、
    「\ `MyBatis 3 REFERENCE DOCUMENTATION(Configuration XML-typeAliases-) <http://mybatis.github.io/mybatis-3/configuration.html#typeAliases>`_ \」を参照されたい。

|

.. _DataAccessMyBatis3HowToUseSettingsMappingNullAndJdbcType:

NULL値とJDBC型のマッピング設定
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

| 使用しているデータベース(JDBCドライバ)によっては、カラム値をnullに設定する際に、エラーが発生する場合がある。
| この事象は、JDBCドライバが\ ``null``\値の設定と認識できるJDBC型を指定する事で、解決する事ができる。

| \ ``null``\値を設定した際に、以下の様なスタックトレースを伴うエラーが発生した場合は、\ ``null``\値とJDBC型のマッピングが必要となる。
| MyBatis3のデフォルトでは、\ ``OTHER``\と呼ばれる汎用的なJDBC型が指定されるが、\ ``OTHER``\だとエラーとなるJDBCドライバもある。

 .. code-block:: guess
    :emphasize-lines: 1

    java.sql.SQLException: Invalid column type: 1111
        at oracle.jdbc.driver.OracleStatement.getInternalType(OracleStatement.java:3916) ~[ojdbc6-11.2.0.2.0.jar:11.2.0.2.0]
        at oracle.jdbc.driver.OraclePreparedStatement.setNullCritical(OraclePreparedStatement.java:4541) ~[ojdbc6-11.2.0.2.0.jar:11.2.0.2.0]
        at oracle.jdbc.driver.OraclePreparedStatement.setNull(OraclePreparedStatement.java:4523) ~[ojdbc6-11.2.0.2.0.jar:11.2.0.2.0]
        ...

 .. note:: **Oracle使用時の動作について**
 
    データベースにOracleを使用する場合は、デフォルトの設定のままだとエラーが発生する事が確認されている。
    バージョンによって動作がかわる可能性はあるが、Oracleを使う場合は、設定の変更が必要になる可能性がある事を記載しておく。

    エラーが発生する事が確認されているバージョンは、Oracle 11g R1で、JDBC型の\ ``NULL`` \型をマッピングするように設定を変更することで、
    エラーを解決する事できる。

|

以下に、MyBatis3のデフォルトの動作を変更する方法を示す。

- mybatis-config.xml

 .. code-block:: xml

    <?xml version="1.0" encoding="UTF-8" ?>
    <!DOCTYPE configuration PUBLIC "-//mybatis.org/DTD Config 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-config.dtd">
    <configuration>

        <settings>
            <!-- (1) -->
            <setting name="jdbcTypeForNull" value="NULL" />
        </settings>

    </configuration>

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
   :header-rows: 1
   :widths: 10 80

   * - 項番
     - 説明
   * - (1)
     - jdbcTypeForNullに、JDBC型を指定する。

       上記例では、\ ``null``\値のJDBC型として\ ``NULL``\型を指定している。



 .. tip:: **項目単位で解決する方法について**

    別の解決方法として、\ ``null``\値が設定される可能性があるプロパティのインラインパラメータに、
    Java型に対応する適切なJDBC型を個別に指定する方法もある。

    ただし、インラインパラメータで個別に指定した場合、マッピングファイルの記述量及び指定ミスが発生する可能性が増えることが予想されるため、
    本ガイドラインとしては、全体の設定でエラーを解決することを推奨している。
    全体の設定を変更してもエラーが解決しない場合は、エラーが発生するプロパティについてのみ、個別に設定を行えばよい。


|


.. _DataAccessMyBatis3HowToUseSettingsTypeHandler:

TypeHandlerの設定
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

TypeHandlerは、JavaクラスとJDBC型をマッピングする時に使用される。

具体的には、

* SQLを発行する際に、Javaクラスのオブジェクトを\ ``java.sql.PreparedStatement`` \のバインドパラメータとして設定する
* SQLの発行結果として取得した\ ``java.sql.ResultSet`` \から値を取得する

際に、使用される。

プリミティブ型やプリミティブラッパ型などの一般的なJavaクラスについては、MyBatis3からTypeHandlerが提供されており、
特別な設定を行う必要はない。

 .. tip::

    MyBatis3から提供されているTypeHandlerについては、
    「\ `MyBatis 3 REFERENCE DOCUMENTATION(Configuration XML-typeHandlers-) <http://mybatis.github.io/mybatis-3/configuration.html#typeHandlers>`_ \」を参照されたい。

 .. tip:: **Enum型のマッピングについて**

    MyBatis3のデフォルトの動作では、Enum型はEnumの定数名(文字列)とマッピングされる。

    下記のようなEnum型の場合は、
    \ ``"WAITING_FOR_ACTIVE"`` \, \ ``"ACTIVE"`` \, \ ``"EXPIRED"`` \, \ ``"LOCKED"`` \
    という文字列とマッピングされてテーブルに格納される。

     .. code-block:: java

        package com.example.domain.model;

        public enum AccountStatus {
            WAITING_FOR_ACTIVE, ACTIVE, EXPIRED, LOCKED
        }

    MyBatisでは、Enum型を数値(定数の定義順)とマッピングする事もできる。数値とマッピングする方法については、
    「\ `MyBatis 3 REFERENCE DOCUMENTATION(Configuration XML-Handling Enums-) <http://mybatis.github.io/mybatis-3/configuration.html#Handling_Enums>`_ \」を参照されたい。


|

TypeHandlerの作成が必要になるケースは、MyBatis3でサポートしていないJavaクラスとJDBC型をマッピングする場合である。

具体的には、

* 容量の大きいファイルデータ(バイナリデータ)を\ ``java.io.InputStream`` \型で保持し、JDBC型の\ ``BLOB`` \型にマッピングする
* 容量の大きいテキストデータを\ ``java.io.Reader`` \型として保持し、JDBC型の\ ``CLOB`` \型にマッピングする
* 本ガイドラインで利用を推奨している「:doc:`Utilities/JodaTime`」の\ ``org.joda.time.DateTime`` \型と、JDBC型の\ ``TIMESTAMP`` \型をマッピングする
* etc ...

場合に、TypeHandlerの作成が必要となる。

上記にあげた3つのTypeHandlerの作成例については、
「:ref:`DataAccessMyBatis3HowToExtendTypeHandler`」を参照されたい。

|

ここでは、作成したTypeHandlerをMyBatisに適用する方法について説明を行う。

- mybatis-config.xml

 .. code-block:: xml

    <?xml version="1.0" encoding="UTF-8" ?>
    <!DOCTYPE configuration PUBLIC "-//mybatis.org/DTD Config 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-config.dtd">
    <configuration>

        <typeHandlers>
            <!-- (1) -->
            <package name="com.example.infra.mybatis.typehandler" />
        </typeHandlers>

    </configuration>

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
   :header-rows: 1
   :widths: 10 80

   * - 項番
     - 説明
   * - (1)
     - MyBatis設定ファイルにTypeHandlerの設定を行う。

       \ ``package``\要素のname 属性に、作成したTypeHandlerが格納されているパッケージ名を指定する。
       指定したパッケージ配下に格納されているTypeHandlerが、MyBatisによって自動検出される。

 .. tip::

    上記例では、指定したパッケージ配下に格納されているTypeHandlerをMyBatisによって自動検出させているが、
    クラス単位に設定する事もできる。

    クラス単位にTypeHandlerを設定する場合は、\ ``typeHandler``\要素を使用する。

    - mybatis-config.xml

     .. code-block:: xml
        :emphasize-lines: 2

        <typeHandlers>
            <typeHandler handler="xxx.yyy.zzz.CustomTypeHandler" />
            <package name="com.example.infra.mybatis.typehandler" />
        </typeHandlers>

    |

    更に、TypeHandlerの中でDIコンテナで管理されているbeanを使用したい場合は、
    bean定義ファイル内でTypeHandlerを指定すればよい。

    - [projectname]-infra.xml

     .. code-block:: xml
        :emphasize-lines: 16-20

        <?xml version="1.0" encoding="UTF-8"?>
        <beans xmlns="http://www.springframework.org/schema/beans"
               xmlns:tx="http://www.springframework.org/schema/tx" xmlns:mybatis="http://mybatis.org/schema/mybatis-spring"
               xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
               xsi:schemaLocation="http://www.springframework.org/schema/beans
            http://www.springframework.org/schema/beans/spring-beans.xsd
            http://www.springframework.org/schema/tx
            http://www.springframework.org/schema/tx/spring-tx.xsd
            http://mybatis.org/schema/mybatis-spring
            http://mybatis.org/schema/mybatis-spring.xsd">

            <bean id="sqlSessionFactory" class="org.mybatis.spring.SqlSessionFactoryBean">
                <property name="dataSource" ref="oracleDataSource" />
                <property name="configLocation"
                    value="classpath:/META-INF/mybatis/mybatis-config.xml" />
                <property name="typeHandlers">
                    <list>
                        <bean class="xxx.yyy.zzz.CustomTypeHandler" />
                    </list>
                </property>
            </bean>

        </beans>

    |

    TypeHandlerを適用するJavaクラスとJDBC型のマッピングの指定は、

    * MyBatis設定ファイル内の\ ``typeHandler``\要素の属性値として指定
    * ``@org.apache.ibatis.type.MappedTypes``\アノテーションと\ ``@org.apache.ibatis.type.MappedJdbcTypes``\アノテーションに指定
    * MyBatis3から提供されているTypeHandlerの基底クラス(\ ``org.apache.ibatis.type.BaseTypeHandler``\)を継承することで指定

    する方法がある。

    詳しくは、「\ `MyBatis 3 REFERENCE DOCUMENTATION(Configuration XML-typeHandlers-) <http://mybatis.github.io/mybatis-3/configuration.html#typeHandlers>`_ \」を参照されたい。


 .. tip::

    上記の設定例は、いずれもアプリケーション全体に適用するための設定方法であったが、
    フィールド毎に個別のTypeHandlerを指定する事も可能である。
    これは、アプリケーション全体に適用しているTypeHandlerを上書きする際に使用する。

     .. code-block:: xml
        :emphasize-lines: 6-7,31-32

        <?xml version="1.0" encoding="UTF-8" ?>
        <!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd" >
        <mapper namespace="com.example.domain.repository.image.ImageRepository">
            <resultMap id="resultMapImage" type="Image">
                <id property="id" column="id" />
                <!-- (2) -->
                <result property="imageData" column="image_data" typeHandler="XxxBlobInputStreamTypeHandler" />
                <result property="createdAt" column="created_at"  />
            </resultMap>
            <select id="findOne" parameterType="string" resultMap="resultMapImage">
                SELECT
                    id
                    ,image_data
                    ,created_at
                FROM
                    t_image
                WHERE
                    id = #{id}
            </select>
            <insert id="create" parameterType="Image">
                INSERT INTO
                    t_image
                (
                    id
                    ,image_data
                    ,created_at
                )
                VALUES
                (
                    #{id}
                    /* (3) */
                    ,#{imageData,typeHandler=XxxBlobInputStreamTypeHandler}
                    ,#{createdAt}
                )
            </insert>
        </mapper>

     .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
     .. list-table::
        :header-rows: 1
        :widths: 10 80

        * - 項番
          - 説明
        * - (2)
          - 検索結果(\ ``ResultSet``\)から値を取得する際は、
            \ ``id``\又は\ ``result``\要素の\ ``typeHandler``\属性に適用するTypeHandlerを指定する。
        * - (3)
          - \ ``PreparedStatement``\に値を設定する際は、
            インラインパラメータの\ ``typeHandler``\属性に適用するTypeHandlerを指定する。

    TypeHandlerをフィールド毎に個別に指定する場合は、TypeHandlerのクラスにTypeAliasを設けることを推奨する。
    TypeAliasの設定方法については、「:ref:`DataAccessMyBatis3HowToUseSettingsTypeAlias`」を参照されたい。



|

.. _DataAccessMyBatis3HowToDababaseAccess:

データベースアクセス処理の実装
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

MyBatis3の機能を使用してデータベースにアクセスするための、具体的な実装方法について説明する。

.. _DataAccessMyBatis3HowToDababaseAccessCreateRepository:

Repositoryインタフェースの作成
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Entity毎にRepositoryインタフェースを作成する。

 .. code-block:: java

    package com.example.domain.repository.todo;

    // (1)
    public interface TodoRepository {
    }
    
 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - JavaのインタフェースとしてRepositoryインタフェースを作成する。
      
        上記例では、\ ``Todo``\というEntityに対するRepositoryインタエースを作成している。

|

.. _DataAccessMyBatis3HowToDababaseAccessCreateMappingFile:

マッピングファイルの作成
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Repositoryインタフェース毎にマッピングファイルを作成する。

 .. code-block:: xml

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
    <!-- (1)  -->
    <mapper namespace="com.example.domain.repository.todo.TodoRepository">
    </mapper>

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - \ ``mapper``\要素の\ ``namespace``\属性に、Repositoryインタフェースの完全修飾クラス名(FQCN)を指定する。

 .. note:: **マッピングファイルの格納先について**
 
    マッピングファイルの格納先は、
    
    * MyBatis3が自動的にマッピングファイルを読み込むために定めたルールに則ったディレクトリ
    * 任意のディレクトリ
    
    のどちらかを選択することができる。
    
    \ **本ガイドラインでは、MyBatis3が定めたルールに則ったディレクトリに格納し、マッピングファイルを自動的に読み込む仕組みを利用することを推奨する。**\
    
    マッピングファイルを自動的に読み込ませるためには、
    Repositoryインタフェースのパッケージ階層と同じ階層で、マッピングファイルをクラスパス上に格納する必要がある。
    
    具体的には、
    \ ``com.example.domain.repository.todo.TodoRepository``\というRepositoryインターフェースに対するマッピングファイル(\ :file:`TodoRepository.xml`\)は、
    \ ``projectName-domain/src/main/resources/com/example/domain/repository/todo``\ディレクトリに格納すればいよい。

|

.. _DataAccessMyBatis3HowToDababaseAccessCrud:

CRUD処理の実装
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
ここからは、基本的なCRUD処理の実装方法と、SQL実装時の考慮点について説明を行う。

基本的なCRUD処理として、以下の処理の実装方法について説明を行う。

* :ref:`DataAccessMyBatis3HowToUseResultSetMapping`
* :ref:`DataAccessMyBatis3HowToUseFind`
* :ref:`DataAccessMyBatis3HowToUseCreate`
* :ref:`DataAccessMyBatis3HowToUseUpdate`
* :ref:`DataAccessMyBatis3HowToUseDelete`
* :ref:`DataAccessMyBatis3HowToUseDynamicSql`

SQL実装時の考慮点として、以下の点について説明を行う。

* :ref:`DataAccessMyBatis3HowToUseLikeEscape`
* :ref:`DataAccessMyBatis3HowToUseSqlInjectionCountermeasure`

|

具体的な実装方法の説明を行う前に、以降の説明で登場するコンポーネントについて、簡単に説明しておく。

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.25\linewidth}|p{0.55\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 25 55

    * - 項番
      - コンポーネント
      - 説明
    * - (1)
      - Entity
      - アプリケーションで扱う業務データを保持するJavaBeanクラス。
      
        Entityの詳細については、「:ref:`domainlayer_entity`」を参照されたい。
    * - (2)
      - Repositoryインタフェース
      - EntityのCRUD操作を行うためのメソッドを定義するインタフェース。
      
        Repositoryの詳細については、「:ref:`repository-label`」を参照されたい。
    * - (3)
      - Serviceクラス
      - 業務ロジックを実行するためのクラス。
      
        Serviceの詳細については、「:ref:`service-label`」を参照されたい。

以降の説明では、「:ref:`domainlayer_entity`」「:ref:`repository-label`」「:ref:`service-label`」を読んでいる前提で説明を行う。

|

.. _DataAccessMyBatis3HowToUseResultSetMapping:

検索結果とJavaBeanのマッピング方法
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Entityの検索処理の説明を行う前に、検索結果とJavaBeanのマッピング方法について説明を行う。

MyBatis3では、検索結果(\ ``ResultSet``\)をJavaBean(Entity)にマッピングする方法として、
自動マッピング と手動マッピングの2つの方法が用意されている。
それぞれ特徴があるので、\ **プロジェクトの特性やアプリケーションで実行するSQLの特性などを考慮して、使用するマッピング方法を決めて頂きたい。**\

 .. note:: **使用するマッピング方法について**

    本ガイドラインでは、

    * シンプルなマッピング(単一オブジェクトへのマッピング)の場合は自動マッピングを使用し、高度なマッピング(関連オブジェクトへのマッピング)が必要な場合は手動マッピングを使用する。
    * 一律手動マッピングを使用する

    の、２つの案を提示する。これは、上記2案のどちらかを選択する事を強制するものではなく、あくまで選択肢のひとつと考えて頂きたい。

    \ **アーキテクトは、自動マッピングと手動マッピングを使うケースの判断基準をプログラマに対して明確に示すことで、
    アプリケーション全体として統一されたマッピング方法が使用されるように心がけてほしい。**\

以下に、自動マッピングと手動マッピングに対して、それぞれの特徴と使用例を説明する。

|

.. _DataAccessMyBatis3HowToUseResultMappingByAuto:

検索結果の自動マッピング
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

MyBatis3では、検索結果(\ ``ResultSet``\)のカラムとJavaBeanのプロパティをマッピングする方法として、
カラム名とプロパティ名を一致させることで、自動的に解決する仕組みを提供している。

 .. note:: **自動マッピングの特徴について**

    自動マッピングを使用すると、マッピングファイルには実行するSQLのみ記述すればよいため、
    マッピングファイルの記述量を減らすことができる点が特徴である。
    
    記述量が減ることで、単純ミスの削減や、カラム名やプロパティ名変更時の修正箇所の削減といった効果も期待できる。
    
    ただし、自動マッピングが行えるのは、単一オブジェクトに対するマッピングのみである。
    ネストした関連オブジェクトに対してマッピングを行いたい場合は、手動マッピングを使用する必要がある。

 .. tip:: **カラム名について**
 
     ここで言うカラム名とは、テーブルの物理的なカラム名ではなく、
     SQLを発行して取得した検索結果(\ ``ResultSet``\)がもつカラム名の事である。
     そのため、AS句を使うことで、物理的なカラム名とJavaBeanのプロパティ名を一致させることは、
     比較的容易に行うことができる。

|

以下に、自動マッピングを使用して検索結果をJavaBeanにマッピングする実装例を示す。

- XxxRepository.xml

 .. code-block:: xml
    :emphasize-lines: 8, 10

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
    <mapper namespace="com.example.domain.repository.todo.TodoRepository">
    
        <select id="findOne" parameterType="string" resultType="Todo">
            SELECT
                todo_id AS "todoId", /* (1) */
                todo_title AS "todoTitle",
                finished, /* (2) */
                created_at AS "createdAt",
                version
            FROM
                t_todo
            WHERE
                todo_id = #{todoId}
        </select>
    
    </mapper>

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
   :header-rows: 1
   :widths: 10 80

   * - 項番
     - 説明
   * - (1)
     - テーブルの物理カラム名とJavaBeanのプロパティ名が異なる場合は、AS句を使用して一致させることで、自動マッピング対象にすることができる。
   * - (2)
     - テーブルの物理カラム名とJavaBeanのプロパティ名が一致している場合は、AS句を指定する必要はない。

- JavaBean

 .. code-block:: java

    package com.example.domain.model;
    
    import java.io.Serializable;
    import java.util.Date;
    
    public class Todo implements Serializable {
    
        private static final long serialVersionUID = 1L;
    
        private String todoId;
    
        private String todoTitle;
    
        private boolean finished;
    
        private Date createdAt;
    
        private long version;
    
        public String getTodoId() {
            return todoId;
        }
    
        public void setTodoId(String todoId) {
            this.todoId = todoId;
        }
    
        public String getTodoTitle() {
            return todoTitle;
        }
    
        public void setTodoTitle(String todoTitle) {
            this.todoTitle = todoTitle;
        }
    
        public boolean isFinished() {
            return finished;
        }
    
        public void setFinished(boolean finished) {
            this.finished = finished;
        }
    
        public Date getCreatedAt() {
            return createdAt;
        }
    
        public void setCreatedAt(Date createdAt) {
            this.createdAt = createdAt;
        }
    
        public long getVersion() {
            return version;
        }
    
        public void setVersion(long version) {
            this.version = version;
        }
    
    }

 .. tip:: **アンダースコア区切りのカラム名とキャメルケース形式のプロパティ名のマッピング方法について**
 
         上記例では、アンダースコア区切りのカラム名とキャメルケース形式のプロパティ名の違いをAS句を使って吸収しているが、
         アンダースコア区切りのカラム名とキャメルケース形式のプロパティ名の違いを吸収するだけならば、
         MyBatis3の設定を変更する事で実現可能である。

|

テーブルの物理カラム名をアンダースコア区切りにしている場合は、
MyBatis設定ファイル(\ :file:`mybatis-config.xml`\)に以下の設定を追加することで、
キャメルケースのJavaBeanのプロパティに自動マッピングする事ができる。

- :file:`mybatis-config.xml`

 .. code-block:: xml
    :emphasize-lines: 8-9

    <?xml version="1.0" encoding="UTF-8" ?>
    <!DOCTYPE configuration
      PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
      "http://mybatis.org/dtd/mybatis-3-config.dtd">
    <configuration>

        <settings>
            <!-- (3) -->
            <setting name="mapUnderscoreToCamelCase" value="true" />
        </settings>

    </configuration>

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (3)
      - \ ``mapUnderscoreToCamelCase`` \を\ `true`\にする設定を追加する。
      
        設定を\ `true`\にすると、アンダースコア区切りのカラム名がキャメルケース形式に自動変換される。
        具体例としては、カラム名が\ ``"todo_id"``\の場合、\ ``"todoId"``\に変換されてマッピングが行われる。

- XxxRepository.xml

 .. code-block:: xml
    :emphasize-lines: 8-12

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
    <mapper namespace="com.example.domain.repository.todo.TodoRepository">
    
        <select id="findOne" parameterType="string" resultType="Todo">
            SELECT
                todo_id, /* (4) */
                todo_title,
                finished,
                created_at,
                version
            FROM
                t_todo
            WHERE
                todo_id = #{todoId}
        </select>
    
    </mapper>

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
   :header-rows: 1
   :widths: 10 80

   * - 項番
     - 説明
   * - (4)
     - アンダースコア区切りのカラム名とキャメルケース形式のプロパティ名の違いを吸収するために、AS句の指定が不要になるため、よりシンプルなSQLとなる。

|

.. _DataAccessMyBatis3HowToUseResultMappingByManual:

検索結果の手動マッピング
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

MyBatis3では、検索結果(\ ``ResultSet``\)のカラムとJavaBeanのプロパティの対応付けを、
マッピングファイルに定義する事で、手動で解決する仕組みを用意している。

 .. note:: **手動マッピングの特徴について**

    手動マッピングを使用すると、検索結果(\ ``ResultSet``\)のカラムとJavaBeanのプロパティの対応付けを、
    マッピングファイルに１項目ずつ定義することになる。
    そのため、マッピングの柔軟性が非常に高く、より複雑なマッピングを実現する事ができる点が特徴である。

    手動マッピングは、
    
     * アプリケーションが扱うデータモデル(JavaBean)と物理テーブルのレイアウトが一致しない
     * JavaBeanがネスト構造になっている(別のJavaBeanをネストしている)

    といった ケースにおいて、検索結果(\ ``ResultSet``\)のカラムとJavaBeanのプロパティをマッピングする際に力を発揮するマッピング方法である。

|

| 以下に、手動マッピングを使用して検索結果をJavaBeanにマッピングする実装例を示す。
| ここでは、手動マッピングの使用方法を示す事が目的なので、自動マッピングでもマッピング可能なもっともシンプルなパターンを例に、説明を行う。

実践的なマッピングの実装例については、
「\ `MyBatis 3 REFERENCE DOCUMENTATION(Mapper XML Files-Advanced Result Maps-) <http://mybatis.github.io/mybatis-3/sqlmap-xml.html#Advanced_Result_Maps>`_ \」を参照されたい。

- XxxRepository.xml

 .. code-block:: xml
    :emphasize-lines: 6-7, 8-9, 10-11, 17-18

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
    <mapper namespace="com.example.domain.repository.todo.TodoRepository">

        <!-- (1) -->
        <resultMap id="todoResultMap" type="Todo">
            <!-- (2) -->
            <id column="todo_id" property="todoId" />
            <!-- (3) -->
            <result column="todo_title" property="todoTitle" />
            <result column="finished" property="finished" />
            <result column="created_at" property="createdAt" />
            <result column="version" property="version" />
        </resultMap>

        <!-- (4) -->
        <select id="findOne" parameterType="string" resultMap="todoResultMap">
            SELECT
                todo_id,
                todo_title,
                finished,
                created_at,
                version
            FROM
                t_todo
            WHERE
                todo_id = #{todoId}
        </select>

    </mapper>

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - \ ``<resultMap>``\要素に、検索結果(\ ``ResultSet``\)とJavaBeanのマッピング定義を行う。
      
        \ ``id``\属性にマッピングを識別するためのIDを、\ ``type``\属性にマッピングするJavaBeanのクラス名(又はエイリアス名)を指定する。
        
        \ ``<resultMap>``\要素の詳細は、「\ `MyBatis 3 REFERENCE DOCUMENTATION(Mapper XML Files-resultMap-) <http://mybatis.github.io/mybatis-3/sqlmap-xml.html#resultMap>`_ \」を参照されたい。
    * - (2)
      - 検索結果(\ ``ResultSet``\)のID(PK)のカラムとJavaBeanのプロパティのマッピングを行う。
      
        ID(PK)のマッピングは、\ ``<id>``\要素を使って指定する。
        \ ``column``\属性には検索結果(\ ``ResultSet``\)のカラム名、\ ``property``\属性にはJavaBeanのプロパティ名を指定する。
        
        \ ``<id>``\要素の詳細は、「\ `MyBatis 3 REFERENCE DOCUMENTATION(Mapper XML Files-id & result-) <http://mybatis.github.io/mybatis-3/sqlmap-xml.html#id__result>`_ \」を参照されたい。
    * - (3)
      - 検索結果(\ ``ResultSet``\)のID(PK)以外のカラムとJavaBeanのプロパティのマッピングを行う。
      
        ID(PK)以外のマッピングは、\ ``<result>``\要素を使って指定する。
        \ ``column``\属性には検索結果(\ ``ResultSet``\)のカラム名、\ ``property``\属性にはJavaBeanのプロパティ名を指定する。

        \ ``<result>``\要素の詳細は、「\ `MyBatis 3 REFERENCE DOCUMENTATION(Mapper XML Files-id & result-) <http://mybatis.github.io/mybatis-3/sqlmap-xml.html#id__result>`_ \」を参照されたい。
    * - (4)
      - \ ``<select>``\要素の\ ``resultMap``\属性に、適用するマッピング定義のIDを指定する。

 .. note:: **id要素とresult要素の使い分けについて**
 
    \ ``<id>``\要素と\ ``<result>``\要素は、
    どちらも検索結果(\ ``ResultSet``\)のカラムとJavaBeanのプロパティをマッピングするための要素であるが、
    ID(PK)カラムに対してマッピングは、\ ``<id>``\要素を使うことを推奨する。
    
    理由は、ID(PK)カラムに対して\ ``<id>``\要素を使用してマッピングを行うと、MyBatis3が提供しているオブジェクトのキャッシュ制御の処理や、
    関連オブジェクトへのマッピングの処理のパフォーマンスを、全体的に向上させることが出来るためである。

|

.. _DataAccessMyBatis3HowToUseFind:

Entityの検索処理
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Entityの検索処理の実装方法について、目的別に説明を行う。

Entityの検索処理の実装方法の説明を読む前に、「:ref:`DataAccessMyBatis3HowToUseResultSetMapping`」を一読して頂きたい。

以降の説明では、アンダースコア区切りのカラム名をキャメルケース形式のプロパティ名に自動でマッピングする設定を有効にした場合の実装例となる。

- :file:`mybatis-config.xml`

 .. code-block:: xml

    <?xml version="1.0" encoding="UTF-8" ?>
    <!DOCTYPE configuration
      PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
      "http://mybatis.org/dtd/mybatis-3-config.dtd">
    <configuration>

        <settings>
            <setting name="mapUnderscoreToCamelCase" value="true" />
        </settings>

    </configuration>

|

.. _DataAccessMyBatis3HowToUseFindOne:

単一キーのEntityの取得
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
PKが単一カラムで構成されるテーブルより、PKを指定してEntityを1件取得する際の実装例を以下に示す。

* Repositoryインタフェースにメソッドを定義する。

 .. code-block:: java

    package com.example.domain.repository.todo;

    import com.example.domain.model.Todo;

    public interface TodoRepository {

        // (1)
        Todo findOne(String todoId);

    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - 上記例では、引数に指定された\ ``todoId``\(PK)に一致するTodoオブジェクトを1件取得するためのメソッドとして、
        \ ``findOne``\メソッドを定義している。

|

* マッピングファイルにSQLを定義する。

 .. code-block:: xml

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
    <mapper namespace="com.example.domain.repository.todo.TodoRepository">

        <!-- (2) -->
        <select id="findOne" parameterType="string" resultType="Todo">
            /* (3) */
            SELECT
                todo_id,
                todo_title,
                finished,
                created_at,
                version
            FROM
                t_todo
            /* (4) */
            WHERE
                todo_id = #{todoId}
        </select>

    </mapper>


 .. tabularcolumns:: |p{0.10\linewidth}|p{0.10\linewidth}|p{0.70\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 10 70

    * - 項番
      - 属性
      - 説明
    * - (2)
      - \-
      - \ ``select``\要素の中に、検索結果が0～1件となるSQLを実装する。
      
        上記例では、ID(PK)が一致するレコードを取得するSQLを実装している。

        \ ``select``\要素の詳細については、
        「`MyBatis3 REFERENCE DOCUMENTATION (Mapper XML Files-select-) <http://mybatis.github.io/mybatis-3/sqlmap-xml.html#select>`_\」を参照されたい。

    * -
      - id
      - Repositoryインタフェースに定義したメソッドのメソッド名を指定する。
    * -
      - parameterType
      - パラメータ完全修飾クラス名(又はエイリアス名)を指定する。
    * -
      - resultType
      - 検索結果(\ ``ResultSet``\)をマッピングするJavaBeanの完全修飾クラス名(又はエイリアス名)を指定する。
      
        手動マッピングを使用する場合は、\ ``resultType``\属性の代わりに\ ``resultMap``\属性を使用して、
        適用するマッピング定義を指定する。
        手動マッピングについては、「:ref:`DataAccessMyBatis3HowToUseResultMappingByManual`」を参照されたい。
    * - (3)
      - \-
      - 取得対象のカラムを指定する。
      
        上記例では、検索結果(\ ``ResultSet``\)をJavaBeanへマッピングする方法として、自動マッピングを使用している。
        自動マッピングについては、「:ref:`DataAccessMyBatis3HowToUseResultMappingByAuto`」を参照されたい。
    * - (4)
      - \-
      - WHERE句に検索条件を指定する。
      
        検索条件にバインドする値は、\ ``#{variableName}``\形式のバインド変数として指定する。上記例では、
        \ ``#{todoId}``\がバインド変数となる。
        
        Repositoryインタフェースの引数の型が\ ``String``\のような単純型の場合は、
        バインド変数名は任意の名前でよいが、引数の型がJavaBeanの場合は、
        バインド変数名にはJavaBeanのプロパティ名を指定する必要がある。

 .. note:: **単純型のバインド変数名について**
 
    \ ``String``\のような単純型の場合は、バインド変数名に制約はないが、メソッドの引数名と同じ値にしておくことを推奨する。

|

* ServiceクラスにRepositoryをDIし、Repositoryインターフェースのメソッドを呼び出す。

 .. code-block:: java

    package com.example.domain.service.todo;

    import javax.inject.Inject;

    import org.springframework.stereotype.Service;
    import org.springframework.transaction.annotation.Transactional;

    import com.example.domain.model.Todo;
    import com.example.domain.repository.todo.TodoRepository;

    @Transactional
    @Service
    public class TodoServiceImpl implements TodoService {

        // (5)
        @Inject
        TodoRepository todoRepository;

        @Transactional(readOnly = true)
        @Override
        public Todo getTodo(String todoId) {
            // (6)
            Todo todo = todoRepository.findOne(todoId);
            if (todo == null) { // (7)
                throw new ResourceNotFoundException(ResultMessages.error().add(
                        "e.ex.td.5001", todoId));
            }
            return todo;
        }

    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (5)
      - ServiceクラスにRepositoryインターフェースをDIする。
    * - (6)
      - Repositoryインターフェースのメソッドを呼び出し、Entityを1件取得する。
    * - (7)
      - 検索結果が0件の場合は\ ``null``\が返却されるため、
        必要に応じてEntityが取得できなかった時の処理を実装する。

        上記例では、Entityが取得できなかった場合は、リソース未検出エラーを発生させている。

|

複合キーのEntityの取得
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
| PKが複数カラムで構成されるテーブルより、PKを指定してEntityを1件取得する際の実装例を以下に示す。
| 基本的な構成は、PKが単一カラムで構成される場合と同じであるが、Repositoryインタフェースのメソッド引数の指定方法が異なる。

* Repositoryインタフェースにメソッドを定義する。

 .. code-block:: java

    package com.example.domain.repository.order;
    
    import org.apache.ibatis.annotations.Param;
    
    import com.example.domain.model.OrderHistory;
    
    public interface OrderHistoryRepository {
    
       // (1)
       OrderHistory findOne(@Param("orderId") String orderId,
               @Param("historyId") int historyId);
    
    }
   
 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - PKを構成するカラムに対応する引数を、メソッドに定義する。

        上記例では、受注の変更履歴を管理するテーブルのPKとして、\ ``orderId``\と\ ``historyId``\を引数に定義している。

 .. tip:: **メソッド引数を複数指定する場合のバインド変数名について**
 
    Repositoryインタフェースのメソッド引数を複数指定する場合は、引数に\ ``@org.apache.ibatis.annotations.Param``\アノテーションを指定することを推奨する。
    \ ``@Param``\アノテーションの\ ``value``\属性には、マッピングファイルから値を参照する際に指定する「バインド変数名」を指定する。
     
    上記例だと、マッピングファイルから\ ``#{orderId}``\及び\ ``#{orderSubId}``\と指定することで、引数に指定された値をSQLにバインドする事ができる。

     .. code-block:: xml
    
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
            "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
        <mapper namespace="com.example.domain.repository.order.OrderHistoryRepository">
    
            <select id="findOne" resultType="OrderHistory">
                SELECT
                    order_id,
                    history_id,
                    order_name,
                    operation_type,
                    created_at"
                FROM
                    t_order_history
                WHERE
                    order_id = #{orderId}
                AND
                    history_id = #{historyId}
            </select>
            
        </mapper>

    \ ``@Param``\アノテーションの指定は必須ではないが、
    指定しないと以下に示すような機械的なバインド変数名を指定する必要がある。
    \ ``@Param``\アノテーションの指定しない場合のバインド変数名は、「"param" + 引数の宣言位置」という名前になるため、
    ソースコードのメンテナンス性及び可読性を損なう要因となる。
    
     .. code-block:: xml
    
        <!-- omitted -->
    
        WHERE
            order_id = #{param1}
        AND
            history_id = #{param2}

        <!-- omitted -->

|

.. _DataAccessMyBatis3HowToUseFindMultiple:

Entityの検索
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
検索結果が0～N件となるSQLを発行し、Entityを複数件取得する際の実装例を以下に示す。

* Entityを複数件取得するためのメソッドを定義する。

 .. code-block:: java

    package com.example.domain.repository.todo;

    import java.util.List;

    import com.example.domain.model.Todo;

    public interface TodoRepository {

        // (1)
        List<Todo> findAllByCriteria(TodoCriteria criteria);

    }


 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - 上記例では、検索条件を保持するJavaBean(\ ``TodoCriteria``\)に一致するTodoオブジェクトをリスト形式で複数件取得するためのメソッドとして、
        \ ``findAllByCriteria``\メソッドを定義している。

|

* 検索条件を保持するJavaBeanを作成する。

 .. code-block:: java

    package com.example.domain.repository.todo;

    import java.io.Serializable;
    import java.util.Date;

    public class TodoCriteria implements Serializable {

        private static final long serialVersionUID = 1L;

        private String title;

        private Date createdAt;

        public String getTitle() {
            return title;
        }

        public void setTitle(String title) {
            this.title = title;
        }

        public Date getCreatedAt() {
            return createdAt;
        }

        public void setCreatedAt(Date createdAt) {
            this.createdAt = createdAt;
        }

    }

 .. note:: **検索条件を保持するためのJavaBeanの作成について**

    検索条件を保持するためのJavaBeanの作成は必須ではないが、格納されている値の役割が明確になるため、
    JavaBeanを作成することを推奨する。ただし、JavaBeanを作成しない方法で実装してもよい。
    
    \ **アーキテクトは、JavaBeanを作成するケースと作成しないケースの判断基準をプログラマに対して明確に示すことで、
    アプリケーション全体として統一された作りになるようにすること。**\

    JavaBeanを作成しない場合の実装例を以下に示す。

     .. code-block:: java

        package com.example.domain.repository.todo;

        import java.util.List;

        import com.example.domain.model.Todo;

        public interface TodoRepository {

            List<Todo> findAllByCriteria(@Param("title") String title,
                    @Param("createdAt") Date createdAt);

        }

    JavaBeanを作成しない場合は、検索条件を1項目ずつ引数に宣言し、
    \ ``@Param``\アノテーションの\ ``value``\属性に「バインド変数名」を指定する。
    上記のようなメソッドを定義することで、複数の検索条件をSQLに引き渡すことができる。

|

* マッピングファイルにSQLを定義する。

 .. code-block:: xml

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
    <mapper namespace="com.example.domain.repository.todo.TodoRepository">

        <!-- (2) -->
        <select id="findAllByCriteria" parameterType="TodoCriteria" resultType="Todo">
            <![CDATA[
            SELECT
                todo_id,
                todo_title,
                finished,
                created_at,
                version
            FROM
                t_todo
            WHERE
                todo_title LIKE #{title} || '%' ESCAPE '~'
            AND
                created_at < #{createdAt}
            /* (3) */
            ORDER BY
                todo_id
            ]]>
        </select>

    </mapper>

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (2)
      - \ ``select``\要素の中に、検索結果が0～N件となるSQLを実装する。
      
        上記例では、\ ``todo_title``\と\ ``created_at``\が指定した条件に一致するTodoレコードを取得する実装している。
    * - (3)
      - ソート条件を指定する。
      
        複数件のレコードを取得する場合は、ソート条件を指定する。
        特に画面に表示するレコードを取得するSQLでは、ソート条件の指定は必須である。

 .. tip:: **CDATAセクションの活用方法について**
 
    SQL内にXMLのエスケープが必要な文字(\ ``"<"``\や\ ``">"``\など)を指定する場合は、
    CDATAセクションを使用すると、SQLの可読性を保つことができる。
    CDATAセクションを使用しない場合は、\ ``"&lt;"``\や\ ``"&gt;"``\といったエンティティ参照文字を指定する必要があり、
    SQLの可読性を損なう要因となる。
    
    上記例では、\ ``created_at``\に対する条件として\ ``"<"``\を使用しているため、CDATAセクションを指定している。

|

.. _DataAccessMyBatis3HowToUseCount:

Entityの件数の取得
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
検索条件に一致するEntityの件数を取得する際の実装例を以下に示す。

* 検索条件に一致するEntityの件数を取得するためのメソッドを定義する。

 .. code-block:: java

    package com.example.domain.repository.todo;

    public interface TodoRepository {

        // (1)
        long countByFinished(boolean finished);

    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - 件数を取得ためのメソッドの返り値は、数値型(\ ``int``\や\ ``long``\など)を指定する。
      
        上記例では、\ ``long``\を指定している。

|

* マッピングファイルにSQLを定義する。

 .. code-block:: xml

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
    <mapper namespace="com.example.domain.repository.todo.TodoRepository">

        <!-- (2) -->
        <select id="countByFinished" parameterType="_boolean" resultType="_long">
            SELECT
                COUNT(*)
            FROM
                t_todo
            WHERE
                finished = #{finished}
        </select>

    </mapper>

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (2)
      - 件数を取得するSQLを実行する。
      
        \ ``resultType``\属性には、返り値の型を指定する。
      
        上記例では、プリミティブ型の\ ``long``\を指定するためのエイリアス名を指定している。

 .. tip:: **プリミティブ型のエイリアス名について**
 
    プリミティブ型のエイリアス名は、先頭に\ ``"_"``\(アンダースコア)を指定する必要がある。
    \ ``"_"``\(アンダースコア)を指定しない場合は、プリミティブのラッパ型(\ ``java.lang.Long``\など)として扱われる。

|

.. _DataAccessMyBatis3HowToUseFindPageUsingMyBatisFunction:

Entityのページネーション検索(MyBatis3標準方式)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
MyBatis3の取得範囲指定機能を使用してEntityを検索する際の実装例を以下に示す。

MyBatisでは取得範囲を指定するクラスとして\ ``org.apache.ibatis.session.RowBounds``\クラスを用意されており、
SQLに取得範囲の条件を記述する必要がない。

 .. warning:: **検索条件に一致するデータ件数が多くなる場合の注意点について**
 
    MyBatis3標準の方式は、検索結果(\ ``ResultSet``\)のカーソルを移動することで、取得範囲外のデータをスキップする方式である。
    そのため、検索条件に一致するデータ件数に比例して、メモリ枯渇やカーソル移動処理の性能劣化が発生する可能性が高くなる。

    カーソルの移動処理は、JDBCの結果セット型に応じて以下の２種類がサポートされており、デフォルトの動作は、
    JDBCドライバのデフォルトの結果セット型に依存する。

    * 結果セット型が\ ``FORWARD_ONLY``\の場合は、\ ``ResultSet#next()``\を繰返し呼び出して取得範囲外のデータをスキップする。
    * 結果セット型が\ ``SCROLL_SENSITIVE``\又は\ ``SCROLL_INSENSITIVE``\の場合は、\ ``ResultSet#absolute(int)``\を呼び出して取得範囲外のデータをスキップする。

    \ ``ResultSet#absolute(int)``\を使用することで、性能劣化を最小限に抑える事ができる可能性はあるが、
    JDBCドライバの実装次第であり、内部で\ ``ResultSet#next()``\と同等の処理が行われている場合は、
    メモリ枯渇や性能劣化が発生する可能性を抑える事はできない。

    \ **検索条件に一致するデータ件数が多くなる可能性がある場合は、MyBatis3標準方式のページネーション検索ではなく、
    SQL絞り込み方式の採用を検討した方がよい。**\

|

* Entityのページネーション検索を行うためのメソッドを定義する。

 .. code-block:: java

    ackage com.example.domain.repository.todo;

    import java.util.List;

    import org.apache.ibatis.session.RowBounds;

    import com.example.domain.model.Todo;

    public interface TodoRepository {

        // (1)
        long countByCriteria(TodoCriteria criteria);

        // (2)
        List<Todo> findPageByCriteria(TodoCriteria criteria,
            RowBounds rowBounds);

    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - 検索条件に一致するEntityの総件数を取得するメソッドを定義する。
    * - (2)
      - 検索条件に一致するEntityの中から、取得範囲のEntityを抽出メソッドを定義する。
      
        定義したメソッドの引数として、取得範囲の情報(offsetとlimit)を保持する\ ``RowBounds``\を指定する。

|

* マッピングファイルにSQLを定義する。

  検索結果から該当範囲のレコードを抽出する処理は、MyBatis3が行うため、SQLで取得範囲のレコードを絞り込む必要がない。

 .. code-block:: xml

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
    <mapper namespace="com.example.domain.repository.todo.TodoRepository">

        <select id="countByCriteria" parameterType="TodoCriteria" resultType="_long">
            <![CDATA[
            SELECT
                COUNT(*)
            FROM
                t_todo
            WHERE
                todo_title LIKE #{title} || '%' ESCAPE '~'
            AND
                created_at < #{createdAt}
            ]]>
        </select>

        <select id="findPageByCriteria" parameterType="TodoCriteria" resultType="Todo">
            <![CDATA[
            SELECT
                todo_id,
                todo_title,
                finished,
                created_at,
                version
            FROM
                t_todo
            WHERE
                todo_title LIKE #{title} || '%' ESCAPE '~'
            AND
                created_at < #{createdAt}
            ORDER BY
                todo_id
            ]]>
        </select>

    </mapper>

 .. note:: **WHERE句の共通化について**
 
    ページネーション検索を実現する場合、「検索条件に一致するEntityの総件数を取得するSQL」と
    「 検索条件に一致するEntityのリストを取得するSQL」で指定するWHERE句は、
    MyBatis3のinclude機能を使って共通化することを推奨する。
    
    上記SQLのWHERE句を共通化した場合、以下のような定義となる。
    詳細は、「:ref:`DataAccessMyBatis3HowToExtendSqlShare`」を参照されたい。

     .. code-block:: xml
        :emphasize-lines: 1, 15, 27

        <sql id="findPageByCriteriaWherePhrase">
            <![CDATA[
            WHERE
                todo_title LIKE #{title} || '%' ESCAPE '~'
            AND
                created_at < #{createdAt}
            ]]>
        </sql>

        <select id="countByCriteria" parameterType="TodoCriteria" resultType="_long">
            SELECT
                COUNT(*)
            FROM
                t_todo
            <include refid="findPageByCriteriaWherePhrase"/>
        </select>

        <select id="findPageByCriteria" parameterType="TodoCriteria" resultType="Todo">
            SELECT
                todo_id,
                todo_title,
                finished,
                created_at,
                version
            FROM
                t_todo
            <include refid="findPageByCriteriaWherePhrase"/>
            ORDER BY
                todo_id
        </select>

 .. note:: **結果セット型を明示的に指定する方法について**

    結果セット型を明示的に指定する場合は、\ ``resultType``\属性に結果セット型を指定する。
    JDBCドライバのデフォルトの結果セット型が、\ ``FORWARD_ONLY``\の場合は、\ ``SCROLL_INSENSITIVE``\を指定することを推奨する。

     .. code-block:: xml
        :emphasize-lines: 2

        <select id="findPageByCriteria" parameterType="TodoCriteria" resultType="Todo"
            resultSetType="SCROLL_INSENSITIVE">
            <!-- omitted -->
        </select>

|

* Serviceクラスにページネーション検索処理を実装する。

 .. code-block:: java

    // omitted

    @Transactional
    @Service
    public class TodoServiceImpl implements TodoService {
    
        @Inject
        TodoRepository todoRepository;
        
        // omitted

        @Transactional(readOnly = true)
        @Override
        public Page<Todo> searchTodos(TodoCriteria criteria, Pageable pageable) {
            // (3)
            long total = todoRepository.countByCriteria(criteria);
            List<Todo> todos;
            if (0 < total) {
                // (4)
                RowBounds rowBounds = new RowBounds(pageable.getOffset(), 
                    pageable.getPageSize());
                // (5)
                todos = todoRepository.findPageByCriteria(criteria, rowBounds);
            } else {
                // (6)
                todos = Collections.emptyList();
            }
            // (7)
            return new PageImpl<>(todos, pageable, total);
        }

        // omitted

    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (3)
      - まず、検索条件に一致するEntityの総件数を取得する。
    * - (4)
      - 検索条件に一致するEntityが存在する場合は、ページネーション検索の取得範囲を指定する\ ``RowBounds``\オブジェクトを生成する。

        \ ``RowBounds``\の第1引数(\ ``offset``\)には「スキップ件数」、
        第２引数(\ ``limit``\)には「最大取得件数」を指定する。
        引数に指定する値、Spring Data Commonsから提供されている\ ``Pageable``\オブジェクトの
        \ ``getOffset``\メソッドと\ ``getPageSize``\メソッドを呼び出して取得した値を指定すればよい。

        具体的には、

        * offsetに\ ``0``\、limitに\ ``20``\を指定した場合、1～20件目
        * offsetに\ ``20``\、limitに\ ``20``\を指定した場合、21～40件目

        が取得範囲となる。

    * - (5)
      - Repositoryのメソッドを呼び出し、検索条件に一致した取得範囲のEntityを取得する。
    * - (6)
      - 検索条件に一致するEntityが存在しない場合は、空のリストを検索結果に設定する。
    * - (7)
      - ページ情報(\ ``org.springframework.data.domain.PageImpl``\)を作成し返却する。

|

.. _DataAccessMyBatis3HowToUseFindPageUsingSqlFilter:

Entityのページネーション検索(SQL絞り込み方式)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
データベースから提供されている範囲検索の仕組みを使用してEntityを検索する際の実装例を以下に示す。

SQL絞り込み方式は、データベースから提供されている範囲検索の仕組みを使用するため、
MyBatis3標準方式に比べて効率的に取得範囲のEntityを取得することができる。

 .. note::

    \ **検索条件に一致するデータ件数が大量にある場合は、SQL絞り込み方式を採用する事を推奨する。**\ 

|

* Entityのページネーション検索を行うためのメソッドを定義する。

 .. code-block:: java

    package com.example.domain.repository.todo;
    
    import java.util.List;
    
    import org.apache.ibatis.annotations.Param;
    import org.springframework.data.domain.Pageable;
    
    import com.example.domain.model.Todo;
    
    public interface TodoRepository {
    
        // (1)
        long countByCriteria(
                @Param("criteria") TodoCriteria criteria);

        // (2)
        List<Todo> findPageByCriteria(
                @Param("criteria") TodoCriteria criteria,
                @Param("pageable") Pageable pageable);
    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - 検索条件に一致するEntityの総件数を取得するメソッドを定義する。
    * - (2)
      - 検索条件に一致するEntityの中から、取得範囲のEntityを抽出メソッドを定義する。

        定義したメソッドの引数として、取得範囲の情報(offsetとlimit)を保持する\ ``org.springframework.data.domain.Pageable``\を指定する。

 .. note:: **引数が1つのメソッドに@Paramアノテーションを指定する理由について**
 
     上記例では、引数が1つのメソッド(\ ``countByCriteria``\)に対して\ ``@Param``\アノテーションを指定している。
     これは、\ ``findPageByCriteria``\メソッド呼び出し時に実行されるSQLとWHERE句を共通化するためである。
     
     \ ``@Param``\アノテーションを使用して引数にバインド変数名を指定することで、
     SQL内で指定するバインド変数名のネスト構造を合わせている。
     
     具体的なSQLの実装例については、次に示す。

|

* マッピングファイルにSQLを定義する。

  SQLで取得範囲のレコードを絞り込む。

 .. code-block:: xml
    :emphasize-lines: 8, 36-37, 38-39

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
    <mapper namespace="com.example.domain.repository.todo.TodoRepository">

        <sql id="findPageByCriteriaWherePhrase">
            <![CDATA[
            /* (3) */
            WHERE
                todo_title LIKE #{criteria.title} || '%' ESCAPE '~'
            AND
                created_at < #{criteria.createdAt}
            ]]>
        </sql>
    
        <select id="countByCriteria" resultType="_long">
            SELECT
                COUNT(*)
            FROM
                t_todo
            <include refid="findPageByCriteriaWherePhrase" />
        </select>
    
        <select id="findPageByCriteria" resultType="Todo">
            SELECT
                todo_id,
                todo_title,
                finished,
                created_at,
                version
            FROM
                t_todo
            <include refid="findPageByCriteriaWherePhrase" />
            ORDER BY
                todo_id
            LIMIT
                #{pageable.pageSize} /* (4) */
            OFFSET
                #{pageable.offset}  /* (4) */
        </select>

    </mapper>

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (3)
      - \ ``countByCriteria``\と\ ``findPageByCriteria``\メソッドの引数に\ ``@Param("criteria")``\を指定しているため、
        SQL内で指定するバインド変数名は\ ``criteria.フィールド名``\の形式となる。
    * - (4)
      - データベースから提供されている範囲検索の仕組みを使用して、必要なレコードのみ抽出する。
      
        \ ``Pageable``\オブジェクトの\ ``offset``\には「スキップ件数」、
        \ ``pageSize``\には「最大取得件数」が格納されている。

        上記例は、データベースとしてH2 Databaseを使用した際の実装例である。

|

* Serviceクラスにページネーション検索処理を実装する。

 .. code-block:: java

    // omitted

    @Transactional
    @Service
    public class TodoServiceImpl implements TodoService {
    
        @Inject
        TodoRepository todoRepository;
        
        // omitted

        @Transactional(readOnly = true)
        @Override
        public Page<Todo> searchTodos(TodoCriteria criteria,
                Pageable pageable) {
            long total = todoRepository.countByCriteriaForPageable(criteria);
            List<Todo> todos;
            if (0 < total) {
                // (5)
                todos = todoRepository.findPageByCriteria(criteria,
                        pageable);
            } else {
                todos = Collections.emptyList();
            }
            return new PageImpl<>(todos, pageable, total);
        }

        // omitted

    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (5)
      - Repositoryのメソッドを呼び出し、検索条件に一致した取得範囲のEntityを取得する。
      
        Repositoryのメソッドを呼び出す際は、引数で受け取った\ ``Pageable``\オブジェクトをそのまま渡せばよい。

|

.. _DataAccessMyBatis3HowToUseCreate:

Entityの登録処理
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Entityの登録方法について、目的別に実装例を説明する。

.. _DataAccessMyBatis3HowToUseCreateOne:

Entityの1件登録
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

Entityを1件登録する際の実装例を以下に示す。

* Repositoryインタフェースにメソッドを定義する。

 .. code-block:: java

    package com.example.domain.repository.todo;
    
    import com.example.domain.model.Todo;
    
    public interface TodoRepository {
    
        // (1)
        void create(Todo todo);
    
    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - 上記例では、引数に指定されたTodoオブジェクトを1件登録するためのメソッドとして、
        \ ``create``\メソッドを定義している。

\

 .. note:: **Entityを登録するメソッドの返り値について**
 
    Entityを登録するメソッドの返り値は、基本的には\ ``void``\でよい。

    ただし、SELECTした結果をINSERTするようなSQLを発行する場合は、
    アプリケーション要件に応じて\ ``boolean``\や数値型(\ ``int``\又は\ ``long``\)を返り値とすること。

    * 返り値として\ ``boolean``\を指定した場合は、登録件数が0件の際は\ ``false``\、登録件数が1件以上の際は\ ``true``\が返却される。
    * 返り値として数値型を指定した場合は、登録件数が返却される。

|

* マッピングファイルにSQLを定義する。

 .. code-block:: xml

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
    <mapper namespace="com.example.domain.repository.todo.TodoRepository">

        <!-- (2) -->
        <insert id="create" parameterType="Todo">
            INSERT INTO
                t_todo
            (
                todo_id,
                todo_title,
                finished,
                created_at,
                version
            )
            /* (3) */
            VALUES
            (
                #{todoId},
                #{todoTitle},
                #{finished},
                #{createdAt},
                #{version}
            )
        </insert>

    </mapper>

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (2)
      - insert要素の中に、INSERTするSQLを実装する。
      
        \ ``id``\属性には、Repositoryインタフェースに定義したメソッドのメソッド名を指定する。

        \ ``insert``\要素の詳細については、
        「`MyBatis3 REFERENCE DOCUMENTATION (Mapper XML Files-insert, update and delete-) <http://mybatis.github.io/mybatis-3/sqlmap-xml.html#insert_update_and_delete>`_\」を参照されたい。

    * - (3)
      - VALUE句にレコード登録時の設定値を指定する。
      
        VALUE句にバインドする値は、#{variableName}形式のバインド変数として指定する。
        上記例では、Repositoryインタフェースの引数としてJavaBean(\ ``Todo```\)を指定しているため、
        バインド変数名にはJavaBeanのプロパティ名を指定する。

|

* ServiceクラスにRepositoryをDIし、Repositoryインターフェースのメソッドを呼び出す。

 .. code-block:: java


    package com.example.domain.service.todo;

    import java.util.UUID;

    import javax.inject.Inject;

    import org.springframework.stereotype.Service;
    import org.springframework.transaction.annotation.Transactional;
    import org.terasoluna.gfw.common.date.DateFactory;

    import com.example.domain.model.Todo;
    import com.example.domain.repository.todo.TodoRepository;

    @Transactional
    @Service
    public class TodoServiceImpl implements TodoService {

        // (4)
        @Inject
        TodoRepository todoRepository;

        @Inject
        DateFactory dateFactory;

        @Override
        public Todo create(Todo todo) {
            // (5)
            todo.setTodoId(UUID.randomUUID().toString());
            todo.setCreatedAt(dateFactory.newDate());
            todo.setFinished(false);
            todo.setVersion(1);
            // (6)
            todoRepository.create(todo);
            // (7)
            return todo;
        }

    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (4)
      - ServiceクラスにRepositoryインターフェースをDIする。
    * - (5)
      - 引数で渡されたEntityオブジェクトに対して、アプリケーション要件に応じて値を設定する。

        上記例では、

        * IDとして「UUID」
        * 登録日時として「システム日時」
        * 完了フラグに「\ ``false``\ : 未完了」
        * バージョンに「\ ``1``\」
        
        を設定している。
    * - (6)
      - Repositoryインターフェースのメソッドを呼び出し、Entityを1件登録する。
    * - (7)
      - 登録したEntityを返却する。
      
        Serviceクラスの処理で登録値を設定する場合は、登録したEntityオブジェクトを返り値として返却する事を推奨する。


|


.. _DataAccessMyBatis3HowToUseGenId:

キーの生成
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

「:ref:`DataAccessMyBatis3HowToUseCreateOne`」では、
Serviceクラスでキー(ID)の生成をする実装例になっているが、
MyBatis3では、マッピングファイル内でキーを生成する仕組みが用意されている。

 .. note:: **MyBatis3のキー生成機能の使用ケースについて**
 
    キーを生成するために、データベースの機能(関数やID列など)を使用する場合は、
    MyBatis3のキー生成機能の仕組みを使用する事を推奨する。

|

キーの生成方法は、2種類用意されている。

* データベースから用意されている関数などを呼び出した結果をキーとして扱う方法
* データベースから用意されているID列(IDENTITY型、AUTO_INCREMENT型など) + JDBC3.0から追加された\ ``Statement#getGeneratedKeys()``\を呼び出した結果をキーとして扱う方法

|

まず、データベースから用意されている関数などを呼び出した結果をキーとして扱う方法について説明する。
下記例は、データベースとしてH2 Databaseを使用している。

 .. code-block:: xml
    :emphasize-lines: 7-11

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
    <mapper namespace="com.example.domain.repository.todo.TodoRepository">

        <insert id="create" parameterType="Todo">
            <!-- (1) -->
            <selectKey keyProperty="todoId" resultType="string" order="BEFORE">
                /* (2) */
                SELECT RANDOM_UUID()
            </selectKey>
            INSERT INTO
                t_todo
            (
                todo_id,
                todo_title,
                finished,
                created_at,
                version
            )
            VALUES
            (
                #{todoId},
                #{todoTitle},
                #{finished},
                #{createdAt},
                #{version}
            )
        </insert>

    </mapper>

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.10\linewidth}|p{0.70\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 10 70

    * - 項番
      - 属性
      - 説明
    * - (1)
      - \-
      - \ ``selectKey``\要素の中に、キーを生成するためのSQLを実装する。

        上記例では、データベースから提供されている関数を使用してUUIDを取得している。

        \ ``selectKey``\の詳細については、
        「`MyBatis3 REFERENCE DOCUMENTATION (Mapper XML Files-insert, update and delete-) <http://mybatis.github.io/mybatis-3/sqlmap-xml.html#insert_update_and_delete>`_\」を参照されたい。
    * -
      - keyProperty
      - 取得したキー値を格納するEntityのプロパティ名を指定する。

        上記例では、Entityの\ ``todoId``\プロパティに生成したキーが設定される。
    * -
      - resultType
      - SQLを発行して取得するキー値の型を指定する。
    * -
      - order
      - キー生成用SQLを実行するタイミング(\ ``BEFORE``\又は\ ``AFTER``\)を指定する。

        * \ ``BEFORE``\を指定した場合、\ ``selectKey``\要素で指定したSQLを実行した結果をEntityに反映した後にINSERT文が実行される。
        * \ ``AFTER``\を指定した場合、INSERT文を実行した後に\ ``selectKey``\要素で指定したSQLを実行され、取得した値がEntityに反映される。
    * - (2)
      - \-
      - \ キーを生成するためのSQLを実装する。

        上記例では、H2 DatabaseのUUIDを生成する関数を呼び出して、キーを生成している。
        キー生成の代表的な実装としては、シーケンスオブジェクトから取得した値を文字列にフォーマットする実装があげられる。

|

次に、データベースから用意されているID列 + JDBC3.0から追加された\ ``Statement#getGeneratedKeys()``\を呼び出した結果をキーとして扱う方法について説明する。
下記例は、データベースとしてH2 Databaseを使用している。

 .. code-block:: xml
    :emphasize-lines: 6-7

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
    <mapper namespace="com.example.domain.repository.audit.AuditLogRepository">

        <!-- (3) -->
        <insert id="create" parameterType="Todo" useGeneratedKeys="true" keyProperty="logId">
            INSERT INTO
                t_audit_log
            (
                level,
                message,
                created_at,
            )
            VALUES
            (
                #{level},
                #{message},
                #{createdAt},
            )
        </insert>
        
    </mapper>

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.10\linewidth}|p{0.70\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 10 70

    * - 項番
      - 属性
      - 説明
    * - (3)
      - useGeneratedKeys
      - \ ``true``\を指定すると、ID列+\ ``Statement#getGeneratedKeys()``\を呼び出してキーを取得する機能が利用可能となる。

        \ ``useGeneratedKeys``\の詳細については、
        「`MyBatis3 REFERENCE DOCUMENTATION (Mapper XML Files-insert, update and delete-) <http://mybatis.github.io/mybatis-3/sqlmap-xml.html#insert_update_and_delete>`_\」を参照されたい。
    * -
      - keyProperty
      - データベース上で自動でインクリメントされたキー値を格納するEntityのプロパティ名を指定する。

        上記例では、INSERT文実行後に、Entityの\ ``logId``\プロパティに\ ``Statement#getGeneratedKeys()``\で取得したキー値が設定される。


|

.. _DataAccessMyBatis3HowToUseCreateMultiple:

Entityの一括登録
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

Entityを一括で登録する際の実装例を以下に示す。

Entityを一括で登録する場合は、

* 複数のレコードを同時に登録するINSERT文を発行する

* JDBCのバッチ更新機能を使用する

方法がある。

JDBCのバッチ更新機能を使用する方法については、「:ref:`DataAccessMyBatis3HowToExtendBatchMode`」を参照されたい。

ここでは、複数のレコードを同時に登録するINSERT文を発行するする方法について説明する。
下記例は、データベースとしてH2 Databaseを使用している。


* Repositoryインタフェースにメソッドを定義する。

 .. code-block:: java

    package com.example.domain.repository.todo;
    
    import java.util.List;

    import com.example.domain.model.Todo;
    
    public interface TodoRepository {
    
        // (1)
        void createAll(List<Todo> todos);
    
    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - 上記例では、引数に指定されたTodoオブジェクトのリストを一括登録するためのメソッドとして、
        \ ``createAll``\メソッドを定義している。

|

* マッピングファイルにSQLを定義する。

 .. code-block:: xml

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
    <mapper namespace="com.example.domain.repository.todo.TodoRepository">

        <insert id="createAll" parameterType="list">
            INSERT INTO
                t_todo
            (
                todo_id,
                todo_title,
                finished,
                created_at,
                version
            )
            /* (2) */
            VALUES
            /* (3) */
            <foreach collection="list" item="todo" separator=",">
            (
                #{todo.todoId},
                #{todo.todoTitle},
                #{todo.finished},
                #{todo.createdAt},
                #{todo.version}
            )
            </foreach>
        </insert>

    </mapper>

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.10\linewidth}|p{0.70\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 10 70

    * - 項番
      - 属性
      - 説明
    * - (2)
      - \-
      - VALUE句にレコード登録時の設定値を指定する。
    * - (3)
      - \-
      - \ ``foreach``\要素を使用して、引数で渡されたTodoオブジェクトのリストに対して繰り返し処理を行う。

        \ ``foreach``\の詳細については、
        「`MyBatis3 REFERENCE DOCUMENTATION (Dynamic SQL-foreach-) <http://mybatis.github.io/mybatis-3/dynamic-sql.html#foreach>`_\」を参照されたい。
    * -
      - collection
      - 処理対象のコレクションを指定する。
      
        上記例では、Repositoryのメソッド引数のリストに対して繰り返し処理を行っている。
        Repositoryメソッドの引数に\ ``@Param``\を指定していない場合は、\ ``"list"``\を指定する。
        \ ``@Param``\を指定した場合は、\ ``@Param``\の\ ``value``\属性に指定した値を指定する。
    * -
      - item
      - リストの中の1要素を保持するローカル変数名を指定する。
      
        \ ``foreach``\要素内のSQLからは、#{ローカル変数名.プロパティ名}の形式でJavaBeanのプロパティにアクセスする事ができる。
    * -
      - separator
      - リスト内の要素間を区切るための文字列を指定する。
      
        上記例では、\ ``","``\を指定することで、要素毎のVALUE句を\ ``","``\で区切っている。

\

 .. note:: **複数のレコードを同時に登録するSQLを使用する際の注意点**

    複数のレコードを同時に登録するSQLを実行する場合は、前述の「:ref:`DataAccessMyBatis3HowToUseGenId`」を使用することが出来ない。

|

* 以下のようなSQLが生成され、実行される。

 .. code-block:: sql

    INSERT INTO
        t_todo
    (
        todo_id,
        todo_title,
        finished,
        created_at,
        version
    )
    VALUES 
    (
        '99243507-1b02-45b6-bfb6-d9b89f044e2d',
        'todo title 1',
        false,
        '09/17/2014 23:59:59.999',
        1
    )
    , 
    (
        '66b096f1-791f-412f-9a0a-ee4a3a9186c2',
        'todo title 2',
        0,
        '09/17/2014 23:59:59.999',
        1
    ) 

 .. tip::

    一括登録するためのSQLは、データベースやバージョンによりサポート状況や文法が異なる。
    以下に主要なデータベースのリファレンスページへのリンクを記載しておく。

    * `Oracle 12c <http://docs.oracle.com/database/121/SQLRF/statements_9014.htm>`_
    * `DB2 10.5 <http://www-01.ibm.com/support/knowledgecenter/SSEPGG_10.5.0/com.ibm.db2.luw.sql.ref.doc/doc/r0000970.html>`_
    * `PostgreSQL 9.3 <http://www.postgresql.org/docs/9.3/static/sql-insert.html>`_
    * `MySQL 5.7 <http://dev.mysql.com/doc/refman/5.7/en/insert.html>`_

|

.. _DataAccessMyBatis3HowToUseUpdate:

Entityの更新処理
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Entityの更新方法について、目的別に実装例を説明する。


.. _DataAccessMyBatis3HowToUseUpdateOne:

Entityの1件更新
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

Entityを1件更新する際の実装例を以下に示す。

 .. note::

     以降の説明では、バージョンカラムを使用して楽観ロックを行う実装例となっているが、
     楽観ロックの必要がない場合は、楽観ロック関連の処理を行う必要はない。

     排他制御の詳細については、「:doc:`ExclusionControl`」を参照されたい。

|

* Repositoryインタフェースにメソッドを定義する。

 .. code-block:: java

    package com.example.domain.repository.todo;
    
    import com.example.domain.model.Todo;
    
    public interface TodoRepository {
    
        // (1)
        boolean update(Todo todo);
    
    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - 上記例では、引数に指定されたTodoオブジェクトを1件更新するためのメソッドとして、
        \ ``update``\メソッドを定義している。

\

 .. note:: **Entityを1件更新するメソッドの返り値について**
 
    Entityを1件更新するメソッドの返り値は、基本的には\ ``boolean``\でよい。

    ただし、更新結果が複数件になった場合にデータ不整合エラーとして扱う必要がある場合は、
    数値型(\ ``int``\又は\ ``long``\)を返り値にし、更新件数が1件であることをチェックする必要がある。
    主キーが更新条件となっている場合は、更新結果が複数件になる事はないので、\ ``boolean``\でよい。

    * 返り値として\ ``boolean``\を指定した場合は、更新件数が0件の際は\ ``false``\、更新件数が1件以上の際は\ ``true``\が返却される。
    * 返り値として数値型を指定した場合は、更新件数が返却される。


|

* マッピングファイルにSQLを定義する。

 .. code-block:: xml

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
    <mapper namespace="com.example.domain.repository.todo.TodoRepository">

        <!-- (2) -->
        <update id="update" parameterType="Todo">
            UPDATE
                t_todo
            SET
                todo_title = #{todoTitle},
                finished = #{finished},
                version = version + 1
            WHERE
                todo_id = #{todoId}
            AND
                version = #{version}
        </update>

    </mapper>

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (2)
      - \ ``update``\要素の中に、UPDATEするSQLを実装する。
      
        \ ``id``\属性には、Repositoryインタフェースに定義したメソッドのメソッド名を指定する。

        \ ``update``\要素の詳細については、
        「`MyBatis3 REFERENCE DOCUMENTATION (Mapper XML Files-insert, update and delete-) <http://mybatis.github.io/mybatis-3/sqlmap-xml.html#insert_update_and_delete>`_\」を参照されたい。

        SET句及びWHERE句にバインドする値は、#{variableName}形式のバインド変数として指定する。
        上記例では、Repositoryインタフェースの引数としてJavaBean(\ ``Todo``\)を指定しているため、
        バインド変数名にはJavaBeanのプロパティ名を指定する。

|

* ServiceクラスにRepositoryをDIし、Repositoryインターフェースのメソッドを呼び出す。

 .. code-block:: java


    package com.example.domain.service.todo;

    import javax.inject.Inject;

    import org.springframework.stereotype.Service;
    import org.springframework.transaction.annotation.Transactional;

    import com.example.domain.model.Todo;
    import com.example.domain.repository.todo.TodoRepository;

    @Transactional
    @Service
    public class TodoServiceImpl implements TodoService {

        // (3)
        @Inject
        TodoRepository todoRepository;

        @Override
        public Todo update(Todo todo) {

            // (4)
            Todo currentTodo = todoRepository.findOne(todo.getTodoId());
            if (currentTodo != null && currentTodo.getVersion() != todo.getVersion()) {
                throw new ObjectOptimisticLockingFailureException(Todo.class, todo
                        .getTodoId());
            }

            // (5)
            currentTodo.setTodoTitle(todo.getTodoTitle());
            currentTodo.setFinished(todo.isFinished());

            // (6)
            boolean updated = todoRepository.update(currentTodo);
            // (7)
            if (!updated) {
                throw new ObjectOptimisticLockingFailureException(Todo.class,
                        currentTodo.getTodoId());
            }
            currentTodo.setVersion(todo.getVersion() + 1);

            return currentTodo;
        }

    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (3)
      - ServiceクラスにRepositoryインターフェースをDIする。
    * - (4)
      - 更新対象のEntityをデータベースより取得する。
      
        上記例では、Entityが更新されている場合(レコードが削除されている場合又はバージョンが更新されている場合)は、
        Spring Frameworkから提供されている楽観ロック例外(\ ``org.springframework.orm.ObjectOptimisticLockingFailureException``\)を発生させている。
    * - (5)
      - 更新対象のEntityに対して、更新内容を反映する。

        上記例では、「タイトル」「完了フラグ」を反映している。更新項目が少ない場合は上記実装例のままでもよいが、
        更新項目が多い場合は、「:doc:`Utilities/Dozer`」を使用することを推奨する。
    * - (6)
      - Repositoryインターフェースのメソッドを呼び出し、Entityを1件更新する。
    * - (7)
      - Entityの更新結果を判定する。
      
        上記例では、Entityが更新されなかった場合(レコードが削除されている場合又はバージョンが更新されている場合)は、
        Spring Frameworkから提供されている楽観ロック例外(\ ``org.springframework.orm.ObjectOptimisticLockingFailureException``\)を発生させている。


 .. tip::

    上記例では、更新処理が成功した後に、

     .. code-block:: java

        currentTodo.setVersion(todo.getVersion() + 1);

    としている。

    これはデータベースに更新したバージョンと、Entityが保持するバージョンを合わせるための処理である。
    
    呼び出し元(ControllerやJSPなど)の処理でバージョンを参照する場合は、
    データベースの状態とEntityの状態を一致させておかないと、
    データ不整合が発生し、アプリケーションが期待通りの動作しない事になる。

|

.. _DataAccessMyBatis3HowToUseUpdateMultiple:

[WIP] Entityの一括更新
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

 .. todo::

    あとで、記載する。

|

.. _DataAccessMyBatis3HowToUseDelete:

Entityの削除処理
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. _DataAccessMyBatis3HowToUseDeleteOne:


Entityの1件削除
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

Entityを1件削除する際の実装例を以下に示す。

 .. note::

     以降の説明では、バージョンカラムを使用した楽観ロックを行う実装例となっているが、
     楽観ロックの必要がない場合は、楽観ロック関連の処理を行う必要はない。

     排他制御の詳細については、「:doc:`ExclusionControl`」を参照されたい。

|

* Repositoryインタフェースにメソッドを定義する。

 .. code-block:: java

    package com.example.domain.repository.todo;

    import com.example.domain.model.Todo;

    public interface TodoRepository {

        // (1)
        boolean delete(Todo todo);

    }


 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - 上記例では、引数に指定されたTodoオブジェクトを1件削除するためのメソッドとして、
        \ ``delete``\メソッドを定義している。


 .. note:: **Entityを1件削除するメソッドの返り値について**

    Entityを1件削除するメソッドの返り値は、基本的には\ ``boolean``\でよい。

    ただし、削除結果が複数件になった場合にデータ不整合エラーとして扱う必要がある場合は、
    数値型(\ ``int``\又は\ ``long``\)を返り値にし、削除件数が1件であることをチェックする必要がある。
    主キーが削除条件となっている場合は、削除結果が複数件になる事はないので、\ ``boolean``\でよい。

    * 返り値として\ ``boolean``\を指定した場合は、削除件数が0件の際は\ ``false``\、削除件数が1件以上の際は\ ``true``\が返却される。
    * 返り値として数値型を指定した場合は、削除件数が返却される。


|

* マッピングファイルにSQLを定義する。


 .. code-block:: xml

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
    <mapper namespace="com.example.domain.repository.todo.TodoRepository">

        <!-- (2) -->
        <delete id="delete" parameterType="Todo">
            DELETE FROM
                t_todo
            WHERE
                todo_id = #{todoId}
            AND
                version = #{version}
        </delete>

    </mapper>

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (2)
      - \ ``delete``\要素の中に、DELETEするSQLを実装する。

        \ ``id``\属性には、Repositoryインタフェースに定義したメソッドのメソッド名を指定する。

        \ ``delete``\要素の詳細については、
        「`MyBatis3 REFERENCE DOCUMENTATION (Mapper XML Files-insert, update and delete-) <http://mybatis.github.io/mybatis-3/sqlmap-xml.html#insert_update_and_delete>`_\」を参照されたい。

        WHERE句にバインドする値は、#{variableName}形式のバインド変数として指定する。
        上記例では、Repositoryインタフェースの引数としてJavaBean(\ ``Todo``\)を指定しているため、
        バインド変数名にはJavaBeanのプロパティ名を指定する。

|

* ServiceクラスにRepositoryをDIし、Repositoryインターフェースのメソッドを呼び出す。


 .. code-block:: java

    package com.example.domain.service.todo;

    import javax.inject.Inject;

    import org.springframework.stereotype.Service;
    import org.springframework.transaction.annotation.Transactional;

    import com.example.domain.model.Todo;
    import com.example.domain.repository.todo.TodoRepository;

    @Transactional
    @Service
    public class TodoServiceImpl implements TodoService {

        // (3)
        @Inject
        TodoRepository todoRepository;

        @Override
        public Todo delete(String todoId, long version) {

            // (4)
            Todo currentTodo = todoRepository.findOne(todoId);
            if (currentTodo != null && currentTodo.getVersion() != version) {
                throw new ObjectOptimisticLockingFailureException(Todo.class, todoId);
            }

            // (5)
            boolean deleted = todoRepository.delete(currentTodo);
            // (6)
            if (!deleted) {
                throw new ObjectOptimisticLockingFailureException(Todo.class,
                        currentTodo.getTodoId());
            }

            return currentTodo;
        }

    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (3)
      - ServiceクラスにRepositoryインターフェースをDIする。
    * - (4)
      - 削除対象のEntityをデータベースより取得する。

        上記例では、Entityが更新されている場合(レコードが削除されている場合又はバージョンが更新されている場合)は、
        Spring Frameworkから提供されている楽観ロック例外(\ ``org.springframework.orm.ObjectOptimisticLockingFailureException``\)を発生させている。
    * - (5)
      - Repositoryインターフェースのメソッドを呼び出し、Entityを1件削除する。
    * - (6)
      - Entityの削除結果を判定する。

        上記例では、Entityが削除されなかった場合(レコードが削除されている場合又はバージョンが更新されている場合)は、
        Spring Frameworkから提供されている楽観ロック例外(\ ``org.springframework.orm.ObjectOptimisticLockingFailureException``\)を発生させている。

|

.. _DataAccessMyBatis3HowToUseDeleteMultiple:


[WIP] Entityの一括削除
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


 .. todo::

    あとで、記載する。

|

.. _DataAccessMyBatis3HowToUseDynamicSql:

動的SQLの実装
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

動的SQLを組み立てる実装例を以下に示す。

MyBatis3では、動的にSQLを組み立てるためのXML要素と、OGNLベースの式（Expression言語）を使用することで、
動的SQLを組み立てる仕組みを提供している。

動的SQLの詳細については、
「`MyBatis3 REFERENCE DOCUMENTATION (Dynamic SQL) <http://mybatis.github.io/mybatis-3/dynamic-sql.html>`_\」を参照されたい。

MyBatis3では、動的にSQLを組み立てるために、以下のXML要素を提供している。


 .. tabularcolumns:: |p{0.10\linewidth}|p{0.10\linewidth}|p{0.70\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 10 70

    * - 項番
      - 要素名
      - 説明
    * - 1.
      - \ ``if``
      - 条件に一致した場合のみ、SQLの組み立てを行うための要素。
    * - 2.
      - \ ``choose``\
      - 複数の選択肢の中から条件に一致する1つを選んで、SQLの組み立てを行うための要素。
    * - 3.
      - \ ``where``\
      - 組み立てたWHERE句に対して、接頭語及び末尾の付与や除去など行うための要素。
    * - 4.
      - \ ``set``\
      - 組み立てたSET句用に対して、、接頭語及び末尾の付与や除去など行うための要素。
    * - 5.
      - \ ``foreach``\
      - コレクションや配列に対して繰り返し処理を行うための要素
    * - 6.
      - \ ``bind``\
      - OGNL式の結果を変数に格納するための要素。

        \ ``bind``\要素を使用して格納した変数は、SQL内で参照する事ができる。

 .. tip::

    一覧には記載していないが、動的SQLを組み立てるためのXML要素として\ ``trim``\要素が提供されている。

    \ ``trim``\要素は、\ ``where``\要素\と\ ``set``\要素をより汎用的にしたXML要素である。

    ほとんどの場合は、\ ``where``\要素と\ ``set``\要素で要件を充たせるため、本ガイドラインでは\ ``trim``\要素の説明は割愛する。
    \ ``trim``\要素が必要になる場合は、
    「`MyBatis3 REFERENCE DOCUMENTATION (Dynamic SQL-trim, where, set-) <http://mybatis.github.io/mybatis-3/dynamic-sql.html#trim_where_set>`_\」
    を参照されたい。

|

if要素の実装
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
\ ``if``\要素は、指定した条件に一致した場合のみ、SQLの組み立てを行うためのXML要素である。

 .. code-block:: xml

    <select id="findAllByCriteria" parameterType="TodoCriteria" resultType="Todo">
        SELECT
            todo_id,
            todo_title,
            finished,
            created_at,
            version
        FROM
            t_todo
        WHERE
            todo_title LIKE #{todoTitle} || '%' ESCAPE '~'
        <!-- (1) -->
        <if test="finished != null">
            AND
                finished = #{finished}
        </if>
        ORDER BY
            todo_id
    </select>


 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - \ ``if``\要素の\ ``test``\属性に、条件を指定する。

        上記例では、検索条件として\ ``finished``\が指定されている場合に、\ ``finished``\カラムに対する条件をSQLに加えている。

上記の動的SQLで生成されるSQL(WHERE句)は、以下2パターンとなる。

 .. code-block:: sql

    -- (1) finished == null
    ...
    WHERE
        todo_title LIKE ? || '%' ESCAPE '~'
    ORDER BY
        todo_id

 .. code-block:: sql

    -- (2) finished != null
    ...
    WHERE
        todo_title LIKE ? || '%' ESCAPE '~'
    AND
        finished = ?
    ORDER BY
        todo_id

|

choose要素の実装
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

\ ``choose``\要素は、複数の選択肢の中から条件に一致する1つを選んで、SQLの組み立てを行うためのXML要素である。

 .. code-block:: xml

    <select id="findAllByCriteria" parameterType="TodoCriteria" resultType="Todo">
        SELECT
            todo_id,
            todo_title,
            finished,
            created_at,
            version
        FROM
            t_todo
        WHERE
            todo_title LIKE #{todoTitle} || '%' ESCAPE '~'
        <!-- (1) -->
        <choose>
            <!-- (2) -->
            <when test="createdAt != null">
                AND
                    created_at <![CDATA[ > ]]> #{createdAt}
            </when>
            <!-- (3) -->
            <otherwise>
                AND
                    created_at <![CDATA[ > ]]> CURRENT_DATE
            </otherwise>
        </choose>
        ORDER BY
            todo_id
    </select>

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - \ ``choose``\要素に中に、\ ``when``\要素と\ ``otherwise``\要素を指定して、SQLを組み立てる条件を指定する。
    * - (2)
      - \ ``when``\要素の\ ``test``\属性に、条件を指定する。

        上記例では、検索条件として\ ``createdAt``\が指定されている場合に、
        \ ``create_at``\カラムの値が指定日以降のレコードを抽出するための条件をSQLに加えている。
    * - (3)
      - \ ``otherwise``\要素に、全ての\ ``when``\要素に一致しない場合時に組み立てるSQLを指定する。

        上記例では、\ ``create_at``\カラムの値が現在日以降のレコード(当日作成されたレコード)を抽出するための条件をSQLに加えている。


上記の動的SQLで生成されるSQL(WHERE句)は、以下2パターンとなる。

 .. code-block:: sql

    -- (1) createdAt!=null
    ...
    WHERE
        todo_title LIKE ? || '%' ESCAPE '~'
    AND
        created_at   >   ?
    ORDER BY
        todo_id

 .. code-block:: sql

    -- (2) createdAt==null
    ...
    WHERE
        todo_title LIKE ? || '%' ESCAPE '~'
    AND
        created_at > CURRENT_DATE
    ORDER BY
        todo_id

|

where要素の実装
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

\ ``where``\要素は、WHERE句を動的に生成するためのXML要素である。

\ ``where``\要素を使用すると、

* WHERE句の付与
* AND句、OR句の除去

などが行われるため、シンプルにWHERE句を組み立てる事ができる。

 .. code-block:: xml

    <select id="findAllByCriteria2" parameterType="TodoCriteria" resultType="Todo">
        SELECT
            todo_id,
            todo_title,
            finished,
            created_at,
            version
        FROM
            t_todo
        <!-- (1) -->
        <where>
            <!-- (2) -->
            <if test="finished != null">
                AND
                    finished = #{finished}
            </if>
            <!-- (3) -->
            <if test="createdAt != null">
                AND
                    created_at <![CDATA[ > ]]> #{createdAt}
            </if>
        </where>
        ORDER BY
            todo_id
    </select>

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - \ ``where``\要素に中で、WHERE句を組み立てるための動的SQLを実装する。

        \ ``where``\要素内で組み立てたSQLに応じて、WHERE句の付与や、AND句及びORの除去などが行われる。
    * - (2)
      - 動的SQLを組み立てる。

        上記例では、検索条件として\ ``finished``\が指定されている場合に、
        \ ``finished``\カラムに対する条件をSQLに加えている。
    * - (3)
      - 動的SQLを組み立てる。

        上記例では、検索条件として\ ``createdAt``\が指定されている場合に、
        \ ``created_at``\カラムに対する条件をSQLに加えている。


上記の動的SQLで生成されるSQL(WHERE句)は、以下4パターンとなる。

 .. code-block:: sql

    -- (1) finished != null && createdAt != null
    ...
    FROM
        t_todo
    WHERE
        finished = ?
    AND
        created_at  >  ?
    ORDER BY
        todo_id

 .. code-block:: sql

    -- (2) finished != null && createdAt == null
    ...
    FROM
        t_todo
    WHERE
        finished = ?
    ORDER BY
        todo_id

 .. code-block:: sql

    -- (3) finished == null && createdAt != null
    ...
    FROM
        t_todo
    WHERE
        created_at  >  ?
    ORDER BY
        todo_id

 .. code-block:: sql

    -- (4) finished == null && createdAt == null
    ...
    FROM
        t_todo
    ORDER BY
        todo_id

|

set要素の実装例
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

\ ``set``\要素は、SET句を動的に生成するためのXML要素である。

\ ``set``\要素を使用すると、

* SET句の付与
* 末尾のカンマの除去

などが行われるため、シンプルにSET句を組み立てる事ができる。

 .. code-block:: xml

    <update id="update" parameterType="Todo">
        UPDATE
            t_todo
        <!-- (1)  -->
        <set>
            version = version + 1,
            <!-- (2) -->
            <if test="todoTitle != null">
                todo_title = #{todoTitle}
            </if>
        </set>
        WHERE
            todo_id = #{todoId}
    </update>

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - \ ``set``\要素に中で、SET句を組み立てるための動的SQLを実装する。

        \ ``set``\要素内で組み立てたSQLに応じて、SET句の付与や、末尾のカンマの除去などが行われる。
    * - (2)
      - 動的SQLを組み立てる。

        上記例では、更新項目として\ ``todoTitle``\が指定されている場合に、
        \ ``todo_title``\カラムを更新カラムとしてSQLに加えている。

上記の動的SQLで生成されるSQLは、以下2パターンとなる。

 .. code-block:: sql

    -- (1) todoTitle != null
    UPDATE
        t_todo
    SET
        version = version + 1,
        todo_title = ?
    WHERE
        todo_id = ?

 .. code-block:: sql

    -- (2) todoTitle == null
    UPDATE
        t_todo
    SET
       version = version + 1
    WHERE
        todo_id = ?

|

foreach要素の実装例
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

\ ``foreach``\要素は、コレクションや配列に対して繰り返し処理を行うためのXML要素である。

 .. code-block:: xml

    <select id="findAllByCreatedAtList" parameterType="list" resultType="Todo">
        SELECT
            todo_id,
            todo_title,
            finished,
            created_at,
            version
        FROM
            t_todo
        <where>
            <!-- (1) -->
            <if test="list != null">
                <!-- (2) -->
                <foreach collection="list" item="date" separator="OR">
                <![CDATA[
                    (created_at >= #{date} AND created_at < DATEADD('DAY', 1, #{date}))
                ]]>
                </foreach>
            </if>
        </where>
        ORDER BY
            todo_id
    </select>


 .. tabularcolumns:: |p{0.10\linewidth}|p{0.15\linewidth}|p{0.65\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 15 65

    * - 項番
      - 属性
      - 説明
    * - (1)
      - \-
      - 繰返し処理を行う対象のコレクション又は配列に対して、\ ``null``\チェックを行う。

        \ ``null``\にならない事がない場合は、このチェックは実装しなくてもよい。
    * - (2)
      - \-
      - \ ``foreach``\要素を使用して、コレクションや配列に対して繰返し処理を行い、動的SQLを組み立てる。

        上記例では、レコードの作成日付が、指定された日付(日付リスト)の何れかと一致するレコードを検索するためのWHERE句を組み立てている。
    * -
      - collection
      - \ ``collection``\属性に、繰返し処理を行うコレクションや配列を指定する。

        上記例では、Repositoryメソッドの引数に指定されたコレクションを指定している。
    * -
      - separator
      - \ ``separator``\属性に、要素間の区切り文字列を指定する。

        上記例では、OR条件のWHERE句を組み立てている。

 .. tip::

    上記例では使用していないが、 \ ``foreach``\要素には、以下の属性が存在する。

     .. tabularcolumns:: |p{0.10\linewidth}|p{0.15\linewidth}|p{0.65\linewidth}|
     .. list-table::
        :header-rows: 1
        :widths: 10 15 65

        * - 項番
          - 属性
          - 説明
        * - (1)
          - open
          - コレクションの先頭要素を処理する前に設定する文字列を指定する。
        * - (2)
          - close
          - コレクションの末尾要素を処理した後に設定する文字列を指定する。
        * - (3)
          - index
          - ループ番号を格納する変数名を指定する。

    \ ``index``\属性を使用するケースはあまりないが、\ ``open``\属性と \ ``close``\属性は、
    IN句などを動的に生成する際に使用される。

    以下に、IN句を作成する際の\ ``foreach``\要素の使用例を記載しておく。

     .. code-block:: xml

        <foreach collection="list" item="statusCode"
                open="AND order_status IN ("
                separator=","
                close=")">
            #{statusCode}
        </foreach>

    以下の様なSQLが組み立てられる。

     .. code-block:: sql

        -- list=['accepted','checking']
        ...
        AND order_status IN (?,?)


| 上記の動的SQLで生成されるSQL(WHERE句)は、以下3パターンとなる。

 .. code-block:: sql

    -- (1) list=null or statusCodes=[]
    ...
    FROM
        t_todo
    ORDER BY
        todo_id

 .. code-block:: sql

    -- (2) list=['2014-01-01']
    ...
    FROM
        t_todo
    WHERE
        (created_at >= ? AND created_at < DATEADD('DAY', 1, ?))
    ORDER BY
        todo_id

 .. code-block:: sql

    -- (3) list=['2014-01-01','2014-01-02']
    ...
    FROM
        t_todo
    WHERE
        (created_at >= ? AND created_at < DATEADD('DAY', 1, ?))
    OR
        (created_at >= ? AND created_at < DATEADD('DAY', 1, ?))
    ORDER BY
        todo_id

|

bind要素の実装例
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

\ ``bind``\要素は、OGNL式の結果を変数に格納するためのXML要素である。

 .. code-block:: xml

    <select id="findAllByCriteria" parameterType="TodoCriteria" resultType="Todo">
        <!-- (1) -->
        <bind name="escapedTodoTitle"
              value="@org.terasoluna.gfw.common.query.QueryEscapeUtils@toLikeCondition(todoTitle)" />
        SELECT
            todo_id,
            todo_title,
            finished,
            created_at,
            version
        FROM
            t_todo
        WHERE
            /* (2) */
            todo_title LIKE #{escapedTodoTitle} || '%' ESCAPE '~'
        ORDER BY
            todo_id
    </select>


 .. tabularcolumns:: |p{0.10\linewidth}|p{0.15\linewidth}|p{0.65\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 15 65

    * - 項番
      - 属性
      - 説明
    * - (1)
      - \-
      - \ ``bind``\要素を使用して、OGNL式の結果を変数に格納する

        上記例では、OGNL式を使ってメソッドを呼び出した結果を、変数に格納している。
    * -
      - name
      - \ ``name``\属性には、変数名を指定する。

        ここで指定した変数名は、SQLのバインド変数として使用する事ができる。
    * -
      - value
      - \ ``value``\属性には、OGNL式を指定する。

        OGNL式を実行した結果が、\ ``name``\属性で指定した変数に格納される。

        上記例では、共通ライブラリから提供しているメソッド(\ ``QueryEscapeUtils#toLikeCondition(String)``\)を呼び出した結果を、
        \ ``escapedTodoTitle``\という変数に格納している。
    * - (2)
      - \-
      - \ ``bind``\要素を使用して作成した変数を、バインド変数として指定する。

        上記例では、\ ``bind``\要素を使用して作成した変数(\ ``escapedTodoTitle``\)を、バインド変数として指定している。


|

.. _DataAccessMyBatis3HowToUseLikeEscape:

[WIP] LIKE検索時のエスケープ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. todo::

    現在チェック中。


| LIKE検索を行う場合は、検索条件として使用する値を、LIKE検索用にエスケープする
  必要がある。
| LIKE検索用のエスケープ処理は、共通ライブラリから提供している
  \ ``org.terasoluna.gfw.common.query.QueryEscapeUtils`` \クラスのメソッドを使
  用することで、実現できる。
| 共通ライブラリから提供しているエスケープ処理の仕様については、
  \ :doc:`DataAccessCommon` \の
  \ :ref:`data-access-common_appendix_like_escape` \を参照されたい。
| 以下に、共通ライブラリから提供しているエスケープ処理の、使用方法について説明
  する。


一致方法をQuery側で指定する場合の使用方法
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

| 一致方法(前方一致、後方一致、部分一致)の指定をJPQLとして指定する場合は、エス
  ケープのみ行うメソッドを使用する。

- XxxRepository.xml

 .. code-block:: xml

    <!-- (1) (2) -->
    <select id="findAllByWord" parameterType="String" resultMap="resultMap_Article">
      SELECT
        *
      FROM
        article
      WHERE
        title LIKE '%' || #{word} || '%' ESCAPE '~'
      OR
        overview LIKE '%' || #{word} || '%' ESCAPE '~'
    </select>

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :widths: 10 80
    :header-rows: 1

    * - 項番
      - 説明
    * - (1)
      - SQL内に、LIKE検索用のワイルドカード(\ ``"%"`` \または\ ``"_"`` \)を指定
        する。上記例では、引数\ ``word`` \の前後に、ワイルドカード(\ ``"%"`` \)
        を指定することで、一致方法を部分一致にしている。
    * - (2)
      - 共通ライブラリから提供しているエスケープ処理は、エスケープ文字として
        \ ``"~"`` \を使用しているため、 LIKE句の後ろに\ ``"ESCAPE '~'"`` \を指
        定する。


- Service

 .. code-block:: java

    @Inject
    XxxRepository xxxRepository;

    @Transactional(readOnly = true)
    public Page<Article> searchArticle(ArticleSearchCriteria criteria,
            Pageable pageable) {

        // (3)
        String escapedWord = QueryEscapeUtils.toLikeCondition(criteria.getWord());

        long total = xxxRepository.countByWord(escapedWord);
        List<Article> contents = null;
        if (0 < total) {
            RowBounds rowBounds =
                new RowBounds(pageable.getOffset(), pageable.getPageSize());
            // (4)
            contents = xxxRepository.findAllByWord(
                    rowBounds, escapedWord);
        } else {
            contents = Collections.emptyList();
        }
        return new PageImpl<Article>(contents, pageable, total);
    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :widths: 10 80
    :header-rows: 1

    * - 項番
      - 説明
    * - (3)
      - LIKE検索の一致方法をQuery側で指定する場合は、
        \ ``QueryEscapeUtils#toLikeCondition(String)`` \メソッドを呼び出し、
        LIKE検索用のエスケープのみ行う。
    * - (4)
      - LIKE検索用にエスケープされた値を、\ ``Repository`` \のバインドパラメー
        タに渡す。同時に渡されるRowBoundsはMyBatisにより取得範囲条件として使用
        される。


一致方法をロジック側で指定する場合の使用方法
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

| 一致方法(前方一致、後方一致、部分一致)をロジック側で判定する場合は、エスケー
  プされた値にワイルドカードを付与するメソッドを使用する。

- XxxRepository.xml

 .. code-block:: xml

    <!-- (1) -->
    <select id="findAllByWord" parameterType="String" resultMap="resultMap_Article">
      SELECT
        *
      FROM
        article
      WHERE
        title LIKE #{word} ESCAPE '~'
      OR
        overview LIKE #{word} ESCAPE '~'
    </select>

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :widths: 10 80
    :header-rows: 1

    * - 項番
      - 説明
    * - (1)
      - SQL内に、LIKE検索用のワイルドカードは、指定しない。


- Service

 .. code-block:: java

    @Inject
    XxxRepository xxxRepository;

    @Transactional(readOnly = true)
    public Page<Article> searchArticle(ArticleSearchCriteria criteria,
            Pageable pageable) {

        // (2)
        String escapedWord  = QueryEscapeUtils
                .toContainingCondition(criteria.getWord());

        long total = xxxRepository.countByWord(escapedWord);
        List<Article> contents = null;
        if (0 < total) {
            RowBounds rowBounds =
                new RowBounds(pageable.getOffset(), pageable.getPageSize());
            // (3)
            contents = xxxRepository.findAllByWord(
                    rowBounds, escapedWord);
        } else {
            contents = Collections.emptyList();
        }
        return new PageImpl<Article>(contents, pageable, total);
    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :widths: 10 80
    :header-rows: 1

    * - 項番
      - 説明
    * - (2)
      - ロジック側で一致方法を指定する場合は、以下の何れかのメソッドを呼び出し、
        LIKE検索用のエスケープとLIKE検索用のワイルドカードを付与する。
        \ ``QueryEscapeUtils#toStartingWithCondition(String)`` \、
        \ ``QueryEscapeUtils#toEndingWithCondition(String)`` \、
        \ ``QueryEscapeUtils#toContainingCondition(String)`` \
    * - (3)
      - LIKE検索用にエスケープ＋ワイルドカードが付与された値を、
        \ ``Repository`` \のバインドパラメータに渡す。同時に渡されるRowBoundsは
        MyBatisにより取得範囲条件として使用される。

.. _DataAccessMyBatis3HowToUseSqlInjectionCountermeasure:

[WIP] SQL Injection対策
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. todo::

    現在チェック中。


| SQLを組み立てる際は、SQL Injectionが発生しないように、注意する必要がある。
| Mybatis3では、SQLに値を埋め込む仕組みを、2つ提供している。

* | バインド変数を使って埋め込む方法。
  | この方法を使用すると、 SQL組み立て後に\ ``java.sql.PreparedStatement`` \を
    使用して、値が埋め込められるため、安全に値を埋め込むことができる。
  | **ユーザからの入力値をSQLに埋め込む場合は、原則バインド変数を使用すること。**

* | 置換変数を使って埋め込む方法。
  | この方法を使用すると、SQLを組み立てるタイミングで、文字列として置換されてし
    まうため、安全な値の埋め込みは、保証されない。

 .. warning::

    ユーザからの入力値を置換変数を使って埋め込むと、SQL Injectionが発生する危険
    性が高くなることを意識すること。ユーザからの入力値を置換変数を使って埋め込
    む必要がある場合は、かならずSQL Injectionが発生しないことを保障するための、
    入力チェックを実施すること。

    基本的には、 **ユーザからの入力値はそのまま使わないことを強く推奨する。**


バインド変数を使って埋め込む方法
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

| バインド変数を使用する場合は、 Inline Parametersを使用する。
| Inline Parametersの使用例は、以下の通り。

 .. code-block:: xml

    <insert id="insert" parameterType="Todo">
      INSERT INTO todo
        (
          todo_id,
          todo_title,
          finished,
          created_at,
          version
        )
      VALUES
        (
          <!-- (3) -->
          #{todoId},
          #{todoTitle},
          #{finished},
          #{createdAt},
          1
        )
    </insert>

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :widths: 10 80
    :header-rows: 1

    * - 項番
      - 説明
    * - (3)
      - バインドする値が格納されているプロパティのプロパティ名を、
        \ ``#{`` \と\ ``}`` \で囲み、バインド変数として指定する。


置換変数を使って埋め込む方法
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

| バインド変数を使用する場合の使用例を、以下に示す。

 .. code-block:: xml

    <select id="findByFinished"
        parameterType="..." resultMap="resultMap_Todo">
      SELECT
        *
      FROM
        todo
      WHERE
        finished = #{finished}
      ORDER BY
        <!-- (4) -->
        created_at ${direction}
    </select>

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :widths: 10 80
    :header-rows: 1

    * - 項番
      - 説明
    * - (4)
      - 置換する値が格納されているプロパティのプロパティ名を\ ``${`` \と
        \ ``}`` \で囲み、置換変数として指定する。上記例では、\ ``${direction}`` \
        の部分は、\ ``"DESC"`` \または\ ``"ASC"`` \で置換される。

 .. warning::

    置換変数による埋め込みは、必ずアプリケーションとして安全な値であることを担
    保した上で、テーブル名、カラム名、ソート条件などに限定して、使用することを
    推奨する。

    例えば、以下のようにコード値と実際に使用する安全な値をペアでMapに格納し、

      .. code-block:: java

        Map<String, String> safeValueMap = new HashMap<String, String>();
        safeValueMap.put("1", "ASC");
        safeValueMap.put("2", "DESC");

    実際の入力はコード値になるようにして、SQLを実行する処理中で変換することが望
    ましい。

      .. code-block:: java

        String direction = safeValueMap.get(input.getDirection());

    \ :doc:`Codelist` \を使用しても良い。



.. _DataAccessMyBatis3HowToExtend:

How to extend
--------------------------------------------------------------------------------


.. _DataAccessMyBatis3HowToExtendSqlShare:

SQL文の共有
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

SQL文を複数のSQLで共有する方法について、説明を行う。

MyBatis3では、 \ ``sql``\要素と\ ``include``\要素を使用することで、
SQL文(又はSQL文の一部)を共有する事ができる。

 .. note:: **SQL文の共有化の使用例**

    ページネーション検索を実現する場合は、「検索条件に一致するEntityの総件数を取得するSQL」と
    「 検索条件に一致するEntityのリストを取得するSQL」のWHERE句は共有した方がよい。

|

マッピングファイルの実装例は以下の通り。

 .. code-block:: xml
    :emphasize-lines: 1-2, 16-17, 29-30

    <!-- (1)  -->
    <sql id="findPageByCriteriaWherePhrase">
        <![CDATA[
        WHERE
            todo_title LIKE #{title} || '%' ESCAPE '~'
        AND
            created_at < #{createdAt}
        ]]>
    </sql>

    <select id="countByCriteria" resultType="_long">
        SELECT
            COUNT(*)
        FROM
            t_todo
        <!-- (2)  -->
        <include refid="findPageByCriteriaWherePhrase"/>
    </select>

    <select id="findPageByCriteria" resultType="Todo">
        SELECT
            todo_id,
            todo_title,
            finished,
            created_at,
            version
        FROM
            t_todo
        <!-- (2)  -->
        <include refid="findPageByCriteriaWherePhrase"/>
        ORDER BY
            todo_id
    </select>


 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :widths: 10 80
    :header-rows: 1

    * - 項番
      - 説明
    * - (1)
      - \ ``sql``\要素の中に、複数のSQLで共有するSQL文を実装する。

        \ ``id``\属性には、マッピングファイル内でユニークとなるIDを指定する。
    * - (2)
      - \ ``include``\要素を使用して、インクルードするSQLを指定する。

        \ ``refid``\属性には、インクルードするSQLのID(\ ``sql``\要素の\ ``id``\属性に指定した値)を指定する。


 .. tip:: **SQLの定義順について**

    共有されるSQLの定義(\ ``sql``\要素)は、
    インクルードする側のSQLの定義(\ ``select``\、\ ``insert``\、\ ``update``\、\ ``delete``\要素)より前に記述する必要がある。

|

|

.. _DataAccessMyBatis3HowToExtendTypeHandler:


TypeHandlerの実装
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

MyBatis3の標準でサポートされていないJavaクラスとのマッピングが必要だったり、
MyBatis3標準の振る舞いを変更する必要がある場合は、独自のTypeHandlerの作成が必要となる。

以下に、

* :ref:`DataAccessMyBatis3HowToExtendTypeHandlerBlob`
* :ref:`DataAccessMyBatis3HowToExtendTypeHandlerClob`
* :ref:`DataAccessMyBatis3HowToExtendTypeHandlerJoda`

を例に、TypeHandlerの実装方法について説明する。

作成したTypeHandlerをアプリケーションに適用する方法については、
「:ref:`DataAccessMyBatis3HowToUseSettingsTypeHandler`」を参照されたい。

 .. note:: **BLOB用とCLOB用の実装例の前提条件について**

    BLOBとCLOBの実装例では、JDBC 4.0から追加されたメソッドを使用している。

    JDBC 4.0との互換性のないJDBCドライバや3rdパーティのラッパクラスなどを使用する場合は、
    以下に説明する実装例では動作しない可能性がある点を補足しておく。
    JDBC 4.0との互換性がない環境で動作させる場合は、
    利用するJDBCドライバの互換バージョンを意識した実装に変更する必要がある。

    例えば、PostgreSQL9.3用のJDBCドライバ(\ ``postgresql-9.3-1102-jdbc41.jar``\)では、
    JDBC 4.0から追加された多くのメソッドが、未実装の状態である。

|

.. _DataAccessMyBatis3HowToExtendTypeHandlerBlob:

BLOB用のTypeHandlerの実装
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

MyBatis3では、BLOBを\ ``byte[]``\にマッピングするためのTypeHandlerを提供している。
ただし、扱うデータの容量が大きい場合は、\ ``java.io.InputStream``\とマッピングが必要なケースがある。

以下に、BLOBと\ ``java.io.InputStream``\をマッピングするためのTypeHandlerの実装例を示す。

 .. code-block:: java

    package com.example.infra.mybatis.typehandler;

    import org.apache.ibatis.type.BaseTypeHandler;
    import org.apache.ibatis.type.JdbcType;
    import org.apache.ibatis.type.MappedTypes;

    import java.io.InputStream;
    import java.sql.*;

    // (1)
    public class BlobInputStreamTypeHandler extends BaseTypeHandler<InputStream> {

        // (2)
        @Override
        public void setNonNullParameter(PreparedStatement ps, int i, InputStream parameter,
                                        JdbcType jdbcType) throws SQLException {
            ps.setBlob(i, parameter);
        }

        // (3)
        @Override
        public InputStream getNullableResult(ResultSet rs, String columnName)
                throws SQLException {
            return toInputStream(rs.getBlob(columnName));
        }

        // (3)
        @Override
        public InputStream getNullableResult(ResultSet rs, int columnIndex)
                throws SQLException {
            return toInputStream(rs.getBlob(columnIndex));
        }

        // (3)
        @Override
        public InputStream getNullableResult(CallableStatement cs, int columnIndex)
                throws SQLException {
            return toInputStream(cs.getBlob(columnIndex));
        }

        private InputStream toInputStream(Blob blob) throws SQLException {
            // (4)
            if (blob == null) {
                return null;
            } else {
                return blob.getBinaryStream();
            }
        }

    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - MyBatis3から提供されている\ ``BaseTypeHandler``\を親クラスに指定する。

        その際、\ ``BaseTypeHandler``\のジェネリック型には、\ ``InputStream``\を指定する。
    * - (2)
      - \ ``InputStream``\を\ ``PreparedStatement``\に設定する処理を実装する。
    * - (3)
      - \ ``ResultSet``\又は\ ``CallableStatement``\から取得した\ ``Blob``\から\ ``InputStream``\を取得し、返り値として返却する。
    * - (4)
      - \ ``null``\を許可するカラムの場合、取得した\ ``Blob``\が\ ``null``\になる可能性があるため、
        \ ``null``\チェックを行ってから\ ``InputStream``\を取得する必要がある。

        上記実装例では、3つのメソッドで同じ処理が必要になるため、privateメソッドを作成している。

|

.. _DataAccessMyBatis3HowToExtendTypeHandlerClob:

CLOB用のTypeHandlerの実装
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

MyBatis3では、CLOBを\ ``java.lang.String``\にマッピングするためのTypeHandlerを提供している。
ただし、扱うデータの容量が大きい場合は、\ ``java.io.Reader``\とマッピングが必要なケースがある。

以下に、CLOBと\ ``java.io.Reader``\をマッピングするためのTypeHandlerの実装例を示す。

 .. code-block:: java

    package com.example.infra.mybatis.typehandler;

    import org.apache.ibatis.type.BaseTypeHandler;
    import org.apache.ibatis.type.JdbcType;

    import java.io.Reader;
    import java.sql.*;

    // (1)
    public class ClobReaderTypeHandler extends BaseTypeHandler<Reader> {

        // (2)
        @Override
        public void setNonNullParameter(PreparedStatement ps, int i, Reader parameter,
                                        JdbcType jdbcType) throws SQLException {
            ps.setClob(i, parameter);
        }

        // (3)
        @Override
        public Reader getNullableResult(ResultSet rs, String columnName)
            throws SQLException {
            return toReader(rs.getClob(columnName));
        }

        // (3)
        @Override
        public Reader getNullableResult(ResultSet rs, int columnIndex)
            throws SQLException {
            return toReader(rs.getClob(columnIndex));
        }

        // (3)
        @Override
        public Reader getNullableResult(CallableStatement cs, int columnIndex)
            throws SQLException {
            return toReader(cs.getClob(columnIndex));
        }

        private Reader toReader(Clob clob) throws SQLException {
            // (4)
            if (clob == null) {
                return null;
            } else {
                return clob.getCharacterStream();
            }
        }

    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - MyBatis3から提供されている\ ``BaseTypeHandler``\を親クラスに指定する。

        その際、\ ``BaseTypeHandler``\のジェネリック型には、\ ``InputStream``\を指定する。
    * - (2)
      - \ ``InputStream``\を\ ``PreparedStatement``\に設定する処理を実装する。
    * - (3)
      - \ ``ResultSet``\又は\ ``CallableStatement``\から取得した\ ``Blob``\から\ ``InputStream``\を取得し、返り値として返却する。
    * - (4)
      - \ ``null``\を許可するカラムの場合、取得した\ ``Blob``\が\ ``null``\になる可能性があるため、
        \ ``null``\チェックを行ってから\ ``InputStream``\を取得する必要がある。

        上記実装例では、3つのメソッドで同じ処理が必要になるため、privateメソッドを作成している。

|

.. _DataAccessMyBatis3HowToExtendTypeHandlerJoda:

Joda-Time用のTypeHandlerの実装
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

| MyBatis3では、Joda-Timeのクラス(\ ``org.joda.time.DateTime``\ 、\ ``org.joda.time.LocalDateTime``\、\ ``org.joda.time.LocalDate``\など)はサポートされていない。
| そのため、EntityクラスのフィールドにJoda-Timeのクラスを使用する場合は、Joda-Time用のTypeHandlerを用意する必要がある。

``org.joda.time.DateTime``\と\ ``java.sql.Timestamp``\をマッピングするためのTypeHandlerの実装例を、以下に示す。

 .. note::

    Jada-Timeから提供されている他のクラス(\ ``LocalDateTime``\、\ ``LocalDate``\、\ ``LocalTime``\など)も同じ要領で実装すればよい。


 .. code-block:: java

    package com.example.infra.mybatis.typehandler;

    import java.sql.CallableStatement;
    import java.sql.PreparedStatement;
    import java.sql.ResultSet;
    import java.sql.SQLException;
    import java.sql.Timestamp;

    import org.apache.ibatis.type.BaseTypeHandler;
    import org.apache.ibatis.type.JdbcType;
    import org.joda.time.DateTime;

    // (1)
    public class DateTimeTypeHandler extends BaseTypeHandler<DateTime> {

        // (2)
        @Override
        public void setNonNullParameter(PreparedStatement ps, int i,
                DateTime parameter, JdbcType jdbcType) throws SQLException {
            ps.setTimestamp(i, new Timestamp(parameter.getMillis()));
        }

        // (3)
        @Override
        public DateTime getNullableResult(ResultSet rs, String columnName)
                throws SQLException {
            return toDateTime(rs.getTimestamp(columnName));
        }

        // (3)
        @Override
        public DateTime getNullableResult(ResultSet rs, int columnIndex)
                throws SQLException {
            return toDateTime(rs.getTimestamp(columnIndex));
        }

        // (3)
        @Override
        public DateTime getNullableResult(CallableStatement cs, int columnIndex)
                throws SQLException {
            return toDateTime(cs.getTimestamp(columnIndex));
        }

        private DateTime toDateTime(Timestamp timestamp) {
            // (4)
            if (timestamp == null) {
                return null;
            } else {
                return new DateTime(timestamp.getTime());
            }
        }

    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - MyBatis3から提供されている\ ``BaseTypeHandler``\を親クラスに指定する。

        その際、\ ``BaseTypeHandler``\のジェネリック型には、\ ``DateTime``\を指定する。
    * - (2)
      - \ ``DateTime``\を\ ``Timestamp``\に変換し、\ ``PreparedStatement``\に設定する処理を実装する。
    * - (3)
      - \ ``ResultSet`\又は\ ``CallableStatement``\から取得した\ ``Timestamp``\を\ ``DateTime``\に変換し、返り値として返却する。
    * - (4)
      - \ ``null``\を許可するカラムの場合、\ ``Timestamp``\が\ ``null``\になる可能性があるため、
        \ ``null``\チェックを行ってから\ ``DateTime``\に変換する必要がある。

        上記実装例では、3つのメソッドで同じ処理が必要になるため、privateメソッドを作成している。


|

.. _DataAccessMyBatis3HowToExtendResultHandler:

[WIP] ResultHandlerの実装
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. todo::

    現在チェック中。


| 検索結果が大量データの場合で、全データ取得後に業務ロジックを実行するとリソー
  ス問題が発生する場合がある。
| この時、検索結果のCSV出力など1件ごとに処理することが可能であればResultHandler
  を使用することでリソースの消費量を抑えることができる。

- TodoRepository.xml

 .. code-block:: xml

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE mapper PUBLIC "-//mybatis.org/DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
    <!-- (1) -->
    <mapper namespace="todo.domain.repository.todo.TodoRepository">
        <resultMap id="todoResultMap" type="Todo">
            <result property="todoId" column="todo_id" />
            <result property="todoTitle" column="todo_title" />
            <result property="finished" column="finished" />
            <result property="createAt" column="create_at" />
        </resultMap>

        <!-- (2) -->
        <select id="createCsvFile" resultMap="todoResultMap">
          SELECT
            todo_id,
            todo_title,
            finished,
            create_at
          FROM
            todo
        </select>

    </mapper>

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - namespace属性に、SQL処理とマッピングするJavaインタフェースクラスを指定
        する。
    * - (2)
      - id属性とメソッド名、resultMap属性と戻り値クラスが対応する。

- TodoResultHandler.java

 .. code-block:: java

    package todo.domain.service.todo;

    import java.io.PrintWriter;
    import todo.domain.model.Todo;

    // (1)
    public class TodoResultHandler implements ResultHandler, AutoCloseable {

        private PrintWriter printWriter = null;

        TodoResultHandler(PrintWriter printWriter) {
            this.printWriter = printWriter;
        }

        // (2)
        @Override
        public void handleResult(ResultContext context) {
            Todo todo = (Todo) context.getResultObject();

            if (printWriter != null) {
                printWriter.printf("%s,%s,%s,%s\n", todo.getTodoId(),
                    todo.getTodoTitle(), todo.getFinished(),
                    LocalDate.formDateFields(
                        todo.getCreateAt()).toString("yyyy/MM/dd"));
            }
        }

        @Override
        public void close() {
            printWriter.close();
        }
    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - ResultHandlerインタフェースクラスを実装する。
    * - (2)
      - レコード毎に処理されるhandleResultメソッドをオーバーライドし処理を実装
        する。

- TodoRepository.java

 .. code-block:: java

    package todo.domain.repository.todo;

    import todo.domain.model.Todo;
    import todo.domain.service.todo.TodoResultHandler;

    public interface TodoRepository {

        // (3)
        List<Todo> createCsvFile(TodoResultHandler handler);

    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (3)
      - メソッド名、メソッド戻り値をSQL定義と対応させる。この時、メソッド引数に
        実装したResultHandlerクラスを指定することで、レコード毎にhandleResultが
        処理される。

- TodoService.java

 .. code-block:: java

    package todo.domain.service.todo;

    public interface TodoService {

        // (4)
        void createCsvFile();

    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (4)
      - Controllerから呼ばれるServiceのメソッド名を定義する。

- TodoServiceImpl.java

 .. code-block:: java

    package todo.domain.service.todo;

    // (5)
    @Inject
    TodoRepository todoRepository;

    public class TodoServiceImpl implements TodoService {

        public void createCsvFile() {
            tempFile = File.createTempFile("TodoList", ".csv");
            PrintWriter printWriter = new PrintWriter(
                new BufferedWriter(new FileWriter(tempFile)));
            // (6)
            try (TodoResultHandler handler = new TodoResultHandler(printWriter)) {
                todoRepository.createCsvFile(handler);
            }
        }

    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (5)
      - Injectにより、SQL処理とマッピングされたRepositoryインスタンスが注入され
        る。
    * - (6)
      - メソッドの実行により、SQL処理が実行され、ResultHandler処理が実行され
        る。


|

.. _DataAccessMyBatis3HowToExtendBatchMode:

[WIP] バッチモードの使用
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. todo::

    現在チェック中。

| SQLを実行する場合に、性能向上を目的としたバッチモードが存在する。
| バッチモードは、Preparedステートメントを使用して、同じSQL文でパラメータのみが
  異なる処理を大量に実施する場合に性能向上を期待できる。

 .. warning:: **バッチモード時の注意点**

    バッチモードはinsert、update、delete等、戻り値に検索結果を返さない処理で使
    用することができる。また、通常はinsert、update、deleteを実行した場合、処理
    件数を戻り値として受け取ることができる。しかし、バッチモードで実行された場
    合、Jdbcの仕様により正確な処理件数を返さない。そのため、取得した処理件数を
    ロジックの分岐条件などに使用する事はできない。バッチモードを使用する場合
    は、上記を仕様を考慮したうえで設計する必要がある。

| SQLの実行をバッチ実行する場合、SqlSessionDaoSupportの派生クラスをRepositoryと
  して実装し、作成したRepositoryクラスをBean定義してバッチモードを適用する。

- [projectname]-infra.xml

 .. code-block:: xml

    <?xml version="1.0" encoding="UTF-8"?>
    <beans xmlns="http://www.springframework.org/schema/beans"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:jpa="http://www.springframework.org/schema/data/jpa"
        xmlns:util="http://www.springframework.org/schema/util"
        xsi:schemaLocation="http://www.springframework.org/schema/beans
            http://www.springframework.org/schema/beans/spring-beans.xsd
            http://www.springframework.org/schema/util
            http://www.springframework.org/schema/util/spring-util.xsd
            http://www.springframework.org/schema/data/jpa
            http://www.springframework.org/schema/data/jpa/spring-jpa.xsd">

        <!-- (1) -->
        <bean id="todoBatchRepository"
            class="todo.domain.repository.todo.TodoBatchRepositoryImpl">
            <!-- (2) -->
            <property name="sqlSessionTemplate">
                <bean class="org.mybatis.spring.SqlSessionTemplate">
                    <constructor-arg index="0" ref="sqlSessionFactory" />
                    <!-- (3) -->
                    <constructor-arg index="1" value="BATCH" />
                </bean>
            </property>
        </bean>

    </beans>

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - 作成したSqlSessionDaoSupport派生クラスをbean定義する。
    * - (2)
      - Repository実装クラスに、バッチモードを適用したSqlSessionTemplateを設定
        する。
    * - (3)
      - SqlSessionTemplateの第2引数にBATCHを指定することで、このRepositoryで実
        行されるSQLのみがBATCHモードとなる。


複数件挿入(バッチ実行)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

| 複数件のデータの挿入をバッチ実行する場合、以下のような実装となる。
| 基本的には1件挿入と同じだが、SQL実行時にSqlSessionDaoSupportの派生クラスとし
  て実装し、バッチモードを有効にしたRepositoryで行う。

- TodoRepository.xml

 .. code-block:: xml

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE mapper PUBLIC "-//mybatis.org/DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
    <!-- (1) -->
    <mapper namespace="todo.domain.repository.todo.TodoRepository">

        <!-- (2) -->
        <insert id="insert" parameterType="Todo" resultType="_int">
          INSERT INTO
            todo (
              todo_id,
              todo_title,
              finished,
              create_at
            )
          VALUES (
            #{todo_id},
            #{todo_title},
            #{finished},
            #{create_at}
          )
        </insert>

    </mapper>

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.10\linewidth}|p{0.70\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 10 70

    * - 項番
      - 属性
      - 説明
    * - (1)
      - namespace
      - 定義したSQLとマッピングするJavaインタフェースクラスを指定する。
    * - (2)
      - id
      - マッピングするJavaインタフェースクラスのメソッド名と対応させる。
    * -
      - parameterType
      - 引数となるJavaクラスを指定する。
    * -
      - resultType
      - 戻り値となるJavaクラスを指定する。

- TodoRepository.java

 .. code-block:: java

    package todo.domain.repository.todo;

    import todo.domain.model.Todo;

    public interface TodoRepository {

        // (3)
        int insert(Todo insertTodo);

    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (3)
      - メソッド名、メソッド引数、メソッド戻り値をSQL定義と対応させる。

 .. note::

    バッチモードでSQLを実行する場合、SqlSessionDaoSupportの派生クラスが
    Repository本体となるが内部でMapperを使用するためのSQL定義ファイルとマッピン
    グするインタフェースクラスを作成する。

 .. warning::

    insert処理の結果としてint値を取得する事ができるが、バッチモードで実行した場
    合、この返却値はinsert件数とはならないため使用する事はできない。

- TodoBatchRepository.java

 .. code-block:: java

    package todo.domain.repository.todo;

    import todo.domain.model.Todo;

    public interface TodoBatchRepository {

        // (4)
        int insert(Todo insertTodo);

    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (4)
      - Serviceから呼ばれるRepositoryのメソッド名を定義する。

- TodoBatchRepositoryImpl.java

 .. code-block:: java

    package todo.domain.repository.todo;

    import todo.domain.model.Todo;

    public class TodoBatchRepositoryImpl extends SqlSessionDaoSupport
            implements TodoBatchRepository {

        @Override
        int insert(Todo insertTodo) {
            // (5)
            getSqlSession().getMapper(
                TodoRepository.class).insert(insertTodo);
        }

    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (5)
      - この例では、bean定義でバッチモードを設定する際にMapperScannerConfigure
        の有効外のSqlSessionを使用する設定となっているため、Repositoryの自動
        マッピングが行われない。そのため直接マッピングされたインスタンスを取得
        しメソッドを実行している。

- TodoBatchService.java

 .. code-block:: java

    package todo.domain.service.todo;

    public interface TodoBatchService {

        // (6)
        void insert();

    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (6)
      - Controllerから呼ばれるServiceのメソッド名を定義する。

- TodoBatchServiceImpl.java

 .. code-block:: java

    package todo.domain.service.todo;

    // (7)
    @Inject
    DateFactory dateFactory;

    // (8)
    @Inject
    TodoBatchRepository todoBatchRepository;

    public class TodoBatchServiceImpl implements TodoBatchService {

        public void insert() {
            for (int idx=0; idx<10; idx++) {
                Todo insertTodo = new Todo();
                insertTodo.setTodoId(String.valueOf(idx));
                insertTodo.setTodoTitle("TodoTitle" : String.valueOf(idx));
                insertTodo.setFinished(false);
                insertTodo.setCreateAt(dateFactory.newDate());
                // (9)
                todoBatchRepository.insert(insertTodo);
            }
        }

    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (7)
      - この例では日付を取得するためにDateFactoryを使用している。詳細は
        \ :doc:`SystemDate` \を参照されたい。
    * - (8)
      - Injectにより、SQL処理とマッピングされたバッチモードのRepositoryインスタ
        ンスが注入される。
    * - (9)
      - メソッドの実行により、SQL処理が実行される。この時SQLがバッチ実行され
        る。


複数件更新(バッチ実行)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

| 複数件のデータの更新をバッチ実行する場合、以下のような実装となる。
| 基本的には1件更新と同じだが、SQL実行時にSqlSessionDaoSupportの派生クラスとし
  て実装し、バッチモードを有効にしたRepositoryで行う。

- TodoRepository.xml

 .. code-block:: xml

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE mapper PUBLIC "-//mybatis.org/DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
    <!-- (1) -->
    <mapper namespace="todo.domain.repository.todo.TodoRepository">

        <!-- (2) -->
        <update id="update" parameterType="Todo" resultType="_int">
          UPDATE
            todo
          SET
            finished = #{finished}
          WHERE
            todo_id = #{todoId}
        </update>

    </mapper>

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.10\linewidth}|p{0.70\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 10 70

    * - 項番
      - 属性
      - 説明
    * - (1)
      - namespace
      - 定義したSQLとマッピングするJavaインタフェースクラスを指定する。
    * - (2)
      - id
      - マッピングするJavaインタフェースクラスのメソッド名と対応させる。
    * -
      - parameterType
      - 引数となるJavaクラスを指定する。
    * -
      - resultType
      - 戻り値となるJavaクラスを指定する。

- TodoRepository.java

 .. code-block:: java

    package todo.domain.repository.todo;

    import todo.domain.model.Todo;

    public interface TodoRepository {

        // (3)
        int update(Todo updateTodo);

    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (3)
      - メソッド名、メソッド引数、メソッド戻り値をSQL定義と対応させる。

 .. note::

    バッチモードでSQLを実行する場合、SqlSessionDaoSupportの派生クラスが
    Repository本体となるが内部でMapperを使用するためのSQL定義ファイルとマッピン
    グするインタフェースクラスを作成する。

 .. warning::

    insert処理の結果としてint値を取得する事ができるが、バッチモードで実行した場
    合、この返却値はinsert件数とはならないため使用する事はできない。

- TodoBatchRepository.java

 .. code-block:: java

    package todo.domain.repository.todo;

    import todo.domain.model.Todo;

    public interface TodoBatchRepository {

        // (4)
        int update(Todo updateTodo);

    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (4)
      - Serviceから呼ばれるRepositoryのメソッド名を定義する。

- TodoBatchRepositoryImpl.java

 .. code-block:: java

    package todo.domain.repository.todo;

    import todo.domain.model.Todo;

    public class TodoBatchRepositoryImpl implements TodoBatchRepository {

        @Override
        int update(Todo updateTodo) {
            // (5)
            return getSqlSession().getMapper(
                TodoRepository.class).update(updateTodo);
        }

    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (5)
      - bean定義で個別にバッチモードを設定したRepositoryでは、
        MapperScannerConfigureの設定が適用されていないため、自動でマッピングが
        行われない。そのためマッピングされたインスタンスを取得しメソッドを実行
        している。

- TodoBatchService.java

 .. code-block:: java

    package todo.domain.service.todo;

    public interface TodoBatchService {

        // (6)
        void update();

    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (6)
      - Controllerから呼ばれるServiceのメソッド名を定義する。

- TodoBatchServiceImpl.java

 .. code-block:: java

    package todo.domain.service.todo;

    // (7)
    @Inject
    TodoBatchRepository todoBatchRepository;

    public class TodoBatchServiceImpl implements TodoBatchService {

        public void insert() {
            for (int idx=0; idx<10; idx++) {
                Todo insertTodo = new Todo();
                insertTodo.setTodoId(String.valueOf(idx));
                insertTodo.setFinished(true);
                // (8)
                todoRepository.update(updateTodo);
            }
        }

    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (7)
      - Injectにより、SQL処理とマッピングされたバッチモードのRepositoryインスタ
        ンスが注入される。
    * - (8)
      - メソッドの実行により、SQL処理が実行される。この時SQLがバッチ実行され
        る。


複数件削除(バッチ実行)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

| 複数件のデータの削除をバッチ実行する場合、以下のような実装となる。
| 基本的には1件削除と同じだが、SQL実行時にバッチモードを有効にしたRepositoryで
  行う。

- TodoRepository.xml

 .. code-block:: xml

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE mapper PUBLIC "-//mybatis.org/DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
    <!-- (1) -->
    <mapper namespace="todo.domain.repository.todo.TodoRepository">

        <!-- (2) -->
        <delete id="deleteByTodoId" parameterType="String">
          DELETE FROM
            todo
          WHERE
            todo_id = #{todoId}
        </delete>

    </mapper>

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.10\linewidth}|p{0.70\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 10 70

    * - 項番
      - 属性
      - 説明
    * - (1)
      - namespace
      - 定義したSQLとマッピングするJavaインタフェースクラスを指定する。
    * - (2)
      - id
      - マッピングするJavaインタフェースクラスのメソッド名と対応させる。
    * -
      - parameterType
      - 引数となるJavaクラスを指定する。

- TodoRepository.java

 .. code-block:: java

    package todo.domain.repository.todo;

    import todo.domain.model.Todo;

    public interface TodoRepository {

        // (3)
        void delete(String todoId);

    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (3)
      - メソッド名、メソッド引数、メソッド戻り値をSQL定義と対応させる。

- TodoBatchRepository.java

 .. code-block:: java

    package todo.domain.repository.todo;

    import todo.domain.model.Todo;

    public interface TodoBatchRepository {

        // (4)
        void delete(String todoId);

    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (4)
      - Serviceから呼ばれるRepositoryのメソッド名を定義する。

- TodoBatchRepositoryImpl.java

 .. code-block:: java

    package todo.domain.repository.todo;

    import todo.domain.model.Todo;

    public class TodoBatchRepositoryImpl implements TodoBatchRepository {

        @Override
        void delete(String todoId) {
            // (5)
            getSqlSession().getMapper(TodoRepository.class).delete(todoId);
        }

    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (5)
      - bean定義で個別にバッチモードを設定したRepositoryでは、
        MapperScannerConfigureの設定が適用されていないため、自動でマッピングが
        行われない。そのためマッピングされたインスタンスを取得しメソッドを実行
        している。

- TodoBatchService.java

 .. code-block:: java

    package todo.domain.service.todo;

    public interface TodoBatchService {

        // (6)
        void delete();

    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (6)
      - Controllerから呼ばれるServiceのメソッド名を定義する。

- TodoBatchServiceImpl.java

 .. code-block:: java

    package todo.domain.service.todo;

    // (7)
    @Inject
    TodoBatchRepository todoBatchRepository;

    public class TodoBatchServiceImpl implements TodoBatchService {

        public void delete() {
            for (int idx=0; idx<10; idx++) {
                // (8)
                todoRepository.delete(String.valueOf(idx));
            }
        }

    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (7)
      - Injectにより、SQL処理とマッピングされたバッチモードのRepositoryインスタ
        ンスが注入される。
    * - (8)
      - メソッドの実行により、SQL処理が実行される。この時SQLがバッチ実行され
        る。

|

.. _DataAccessMyBatis3HowToExtendStoredProcedure:

[WIP] ストアドプロシージャの実行方法
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. todo::

    現在チェック中。

| プロシージャの実行は通常のSQL実行と方法は同じで、使用しているデータベースの呼
  出し書式に合わせプロシージャを実行する。

- XxxRepository.xml

 .. code-block:: xml

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
    "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
    <mapper namespace="xxx.yyy.zzz.domain.repository.XxxRepository">

        <!-- (1) -->
        <update id="execProcedure">
          CALL PROCEDURE_NAME()
        </update>

    </mapper>

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.10\linewidth}|p{0.70\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 10 70

    * - 項番
      - 属性
      - 説明
    * - (1)
      -
      - 使用しているRDBMSの書式に合わせプロシージャの実行SQLを記述する。
    * -
      - id
      - マッピングするJavaインタフェースクラスのメソッド名と対応させる。

|

.. _DataAccessMyBatis3Appendix:

Appendix
--------------------------------------------------------------------------------

.. _DataAccessMyBatis3AppendixAboutMapperMechanism:

Mapperインタフェースの仕組みについて
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
| Mapperインタフェースを使用する場合、開発者はMapperインタフェースとマッピングファイルを作成するだけで、SQLを実行する事ができる。
| Mapperインタフェースの実装クラスは、MyBatis3がJDKのProxy機能を使用してアプリケーション実行時に生成されるため、
 開発者がMapperインタフェースの実装クラスを作成する必要はない。

| Mapperインタフェースは、MyBatis3から提供されているインタフェースの継承やアノテーションなどの定義は不要であり、
 単にJavaのインタフェースとして作成すればよい。
| 以下に、Mapperインタフェースとマッピングファイルの作成例、及びアプリケーション(Service)での利用例を示す。
| ここでは、開発者が作成する成果物をイメージしてもらう事が目的なので、コードに対する説明はポイントとなる点に絞って行っている。

- Mapperインタフェースの作成例

  本ガイドラインでは、MyBatis3のMapperインタフェースをRepositoryインタフェースとして使用することを前提としているため、
  インタフェース名は、「Entity名」 + \ ``"TodoRepository"`` \というネーミングにしている。

 .. code-block:: java

    package com.example.domain.repository.todo;

    import com.example.domain.model.Todo;

    public interface TodoRepository {
        Todo findOne(String todoId);
    }

- マッピングファイルの作成例

  マッピングファイルでは、ネームスペースとしてMapperインタフェースのFQCN(Fully Qualified Class Name)を指定し、
  Mapperインタフェースに定義したメソッドの呼び出し時に実行するSQLとの紐づけは、
  各種ステートメントタグ(insert/update/delete/selectタグ)のid属性に、メソッド名を指定する事で行う事ができる。

 .. code-block:: xml
    :emphasize-lines: 4, 12

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE mapper PUBLIC "-//mybatis.org/DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
    <mapper namespace="com.example.domain.repository.todo.TodoRepository">

        <resultMap id="todoResultMap" type="Todo">
            <result column="todo_id" property="todoId" />
            <result column="title" property="title" />
            <result column="finished" property="finished" />
        </resultMap>

        <select id="findOne" parameterType="String" resultMap="todoResultMap">
          SELECT
            todo_id,
            title,
            finished
          FROM
            t_todo
          WHERE
            todo_id = #{todoId}
        </select>

    </mapper>

- アプリケーション(Service)でのMapperインタフェースの使用例

  アプリケーション(Service)からMapperインタフェースのメソッドを呼び出す場合は、Spring(DIコンテナ)によって注入されたMapperオブジェクトのメソッドを呼び出す。
  アプリケーション(Service)は、Mapperオブジェクトのメソッドを呼び出すことで、透過的にSQLが実行され、SQLの実行結果を得ることができる。

 .. code-block:: java
    :emphasize-lines: 12

    package com.example.domain.service.todo;

    import com.example.domain.model.Todo;
    import com.example.domain.repository.todo.TodoRepository;

    public class TodoServiceImpl implements TodoService {

        @Inject
        TodoRepository todoRepository;

        public Todo getTodo(String todoId){
            Todo todo = todoRepository.findOne(todoId);
            if(todo == null){
                throw new ResourceNotFoundException(
                    ResultMessages.error().add("e.ex.td.5001" ,todoId));
            }
            return todo;
        }

    }

|

以下に、Mapperインタフェースのメソッドを呼び出した際に、SQLが実行されるまでの処理フローについて説明を行う。


 .. figure:: images_DataAccessMyBatis3/DataAccessMyBatis3MapperMechanism.png
    :alt: Mapper mechanism
    :width: 100%
    :align: center

    **Picture - Mapper mechanism**

 .. tabularcolumns:: |p{0.1\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80


    * - 項番
      - 説明
    * - (1)
      - アプリケーションは、Mapperインタフェースに定義されているメソッドを呼び出す。

        Mapperインタフェースの実装クラス(MapperインタフェースのProxyオブジェクト)は、実行時にMyBatis3のコンポーネントによって生成される。
    * - (2)
      - MapperインタフェースのProxyオブジェクトは、\ ``MapperProxy`` \のinvokeメソッドを呼び出す。

        \ ``MapperProxy`` \は、Mapperインタフェースのメソッド呼び出しをハンドリングしをハンドリングする役割をもつ。
    * - (3)
      - \ ``MapperProxy`` \は、呼び出されたMapperインタフェースのメソッドに対応する \ ``MapperMethod`` \を生成し、executeメソッドを呼び出す。

        \ ``MapperMethod`` \は、 呼び出されたMapperインタフェースのメソッドに対応する\ ``SqlSession`` \のメソッドを呼び出す役割をもつ。
    * - (4)
      - \ ``MapperMethod`` \は、 \ ``SqlSession`` \のメソッドを呼び出す。

        \ ``SqlSession`` \のメソッドを呼び出す際は、実行するSQLステートメントを特定するためのキー(以降、「ステートメントID」と呼ぶ)を引き渡している。
    * - (5)
      - \ ``SqlSession`` \は、指定されたステートメントIDをキーに、マッピングファイルよりSQLステートメントを取得する。
    * - (6)
      - \ ``SqlSession`` \は、マッピングファイルより取得したSQLステートメントに指定されているバインド変数に値を設定し、SQLを実行する。
    * - (7)
      - Mapperインタフェース(\ ``SqlSession`` \)は、SQLの実行結果をJavaBeanなどに変換して、アプリケーションに返却する。

        件数のカウントや、更新件数などを取得する場合は、プリミティブ型やプリミティブラッパ型などが返却値となるケースもある。


 .. tip:: **ステートメントIDとは**

    ステートメントIDは、実行するSQLステートメントを特定するためのキーであり、
    \ **「MapperインタフェースのFQCN + "." + 呼び出されたMapperインタフェースのメソッド名」** \というルールで生成される。

    \ ``MapperMethod`` \によって生成されたステートメントIDに対応するSQLステートメントをマッピングファイルに定義するためには、
    マッピングファイルのネームスペースに「MapperインタフェースのFQCN」、
    各種ステートメントタグのid属性に「Mapperインタフェースのメソッド名」を指定する必要がある。

|

.. _DataAccessMyBatis3AppendixSettingsTypeAlias:

TypeAliasの設定
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
TypeAliasの設定は、基本的には\ ``package`` \要素を使用してパッケージ単位で設定すればよいが、

* クラス単位でエイリアス名を設定する方法
* デフォルトで付与されるエイリアス名を上書きする方法(任意のエイリアス名を指定する方法)

も用意されている。

TypeAliasをクラス単位に設定
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
TypeAliasの設定は、クラス単位で設定する事もできる。

- :file:`mybatis-config.xml`

 .. code-block:: xml
    :emphasize-lines: 2-4

    <typeAliases>
        <!-- (1) -->
        <typeAlias
            type="com.example.domain.repository.account.AccountSearchCriteria" />
        <package name="com.example.domain.model" />
    </typeAliases>

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
   :header-rows: 1
   :widths: 10 80

   * - 項番
     - 説明
   * - (1)
     - \ ``typeAlias`` \要素の\ ``type`` \属性に、エイリアスを設定するクラスの完全修飾クラス名(FQCN)を指定する。

       上記例だと、\ ``com.example.domain.repository.account.AccountSearchCriteria`` \クラスのエイリアス名は、
       \ ``AccountSearchCriteria`` \(パッケージの部分が除去された部分)となる。
       
       エイリアス名に任意の値を指定したい場合は、\ ``typeAlias`` \要素の\ ``alias`` \属性に任意のエイリアス名を指定することができる。


デフォルトで付与されるエイリアス名の上書き
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
\ ``package`` \要素を使用してエイリアスを設定した場合や、
\ ``typeAlias`` \要素の\ ``alias`` \属性を省略してエイリアスを設定した場合は、
TypeAliasのエイリアス名は、完全修飾クラス名(FQCN)からパッケージの部分が除去された部分となる。

デフォルトで付与されるエイリアス名ではなく、任意のエイリアス名にしたい場合は、
TypeAliasを設定したいクラスに\ ``@org.apache.ibatis.type.Alias`` \アノテーションを指定する事で、
任意のエイリアス名を指定する事ができる。

- エイリアス設定対象のJavaクラス

 .. code-block:: java
    :emphasize-lines: 3

    package com.example.domain.model.book;

    @Alias("BookAuthor") // (1)
    public class Author {
       // ...
    }
    
 .. code-block:: java
    :emphasize-lines: 3

    package com.example.domain.model.article;

    @Alias("ArticleAuthor") // (1)
    public class Author {
       // ...
    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
   :header-rows: 1
   :widths: 10 80

   * - 項番
     - 説明
   * - (1)
     - \ ``@Alias`` \アノテーションの\ ``value`` \属性に、エイリアス名を指定する。

       上記例だと、\ ``com.example.domain.model.book.Author`` \クラスのエイリアス名は、
       \ ``BookAuthor`` \となる。
       
       異なるパッケージの中に同じクラス名のクラスが格納されている場合は、この方法を使用することで、それぞれ異なるエイリアス名を設定する事ができる。
       ただし、本ガイドラインでは、クラス名は重複しないように設計する事を推奨する。
       上記例であれば、クラス名自体を\ ``BookAuthor`` \と\ ``ArticleAuthor`` \にすることを検討して頂きたい。

 .. tip::
 
    TypeAliasの エイリアス名は、
    
     * \ ``typeAlias`` \要素の\ ``alias`` \属性の指定値
     * ``@Alias`` \アノテーションの\ ``value`` \属性の指定値
     * デフォルトで付与されるエイリアス名(完全修飾クラス名からパッケージの部分が除去された部分)
    
    の優先順で適用される。

|

.. _DataAccessMyBatis3AppendixSwitchingSqlByDatabase:

[WIP] データベースによるSQL切替の実装
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. todo::

    現在チェック中。

MyBatis3では、接続に指定しているJDBCドライバからデータベースのベンダー情報を取得して、
実行するSQLを切り替える仕組みを提供している。

この仕組みは、動作環境として複数のデータベースをサポートするようなアプリケーションを構築する際に、
有効である。

- [projectname]-infra.xml

 .. code-block:: xml

    <?xml version="1.0" encoding="UTF-8"?>
    <beans xmlns="http://www.springframework.org/schema/beans"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:jpa="http://www.springframework.org/schema/data/jpa"
        xmlns:util="http://www.springframework.org/schema/util"
        xsi:schemaLocation="http://www.springframework.org/schema/beans
            http://www.springframework.org/schema/beans/spring-beans.xsd
            http://www.springframework.org/schema/util
            http://www.springframework.org/schema/util/spring-util.xsd
            http://www.springframework.org/schema/data/jpa
            http://www.springframework.org/schema/data/jpa/spring-jpa.xsd">

        <!-- (1) -->
        <bean id="vendorProperties"
            class="org.springframework.beans.factory.config.PropertiesFactoryBean">
            <property name="properties">
                <props>
                    <prop key="H2">h2</prop>
                    <prop key="PostgreSQL">postgresql</prop>
                </props>
            </property>
        </bean>

        <!-- (2) -->
        <bean id="databaseIdProvider"
            class="org.apache.ibatis.mapping.VendorDatabaseIdProvider">
            <property name="properties" ref="vendorProperties" />
        </bean>

        <bean id="sqlSessionFactory"
            class="org.mybatis.spring.SqlSessionFactoryBean">
            <property name="dataSource" ref="dataSource" />
            <property name="databaseIdProvider" ref="databaseIdProvider" />
            <property name="configLocation"
                value="classpath:META-INF/mybatis/mybatis-config.xml" />
        </bean>

    </mapper>

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - Jdbcドライバから取得したベンダ情報に含まれるキーと任意の文字列のマッピ
        ングを設定する。
    * - (2)
      - SQL内で変数_databaseIdを取得できるようにdatabaseIdProviderにマッピング
        情報を設定する。

- XxxRepository.xml

 .. code-block:: xml

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" 
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
    <mapper namespace="xxx.yyy.zzz.TodoRepository">

        <update id="callProcedure">
          <if test="_databaseId == 'h2'">
            CALL PROCEDURE_NAME()
          </if>
          <if test="_databaseId == 'postgresql'">
            SELECT PROCEDURE_NAME()
          </if>
        </update>

    </mapper>

|

.. _DataAccessMyBatis3AppendixAcquireRelatedObjectsAtOnce:

[WIP] 関連オブジェクトを１回のSQLで取得する実装例
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. todo::

    現在チェック中。


| テーブル毎にEntityのようなJavaBeanを用意して、データベースにアクセスする際
  に、関連オブジェクトを、1回のSQLでまとめて取得する方法について説明する。
| この方法は、N+1問題を回避する手段としても使用される。

.. warning::

  以下の点に注意して、使用すること。

  * 本例では、使い方を説明するために、すべての関連オブジェクトを、1回のSQLでま
    とめて取得している。しかしながら、実際のプロジェクトで使用する場合は、処理
    で必要となる関連オブジェクトのみ取得するようにすること。なぜなら、使用しな
    い関連オブジェクトを、同時に取得してしまった場合、性能劣化の原因となるケー
    スがあるからである。
  * 使用頻度の低い、1:Nの関係をもつ関連オブジェクトについては、まとめて取得しな
    い。必要なときに、個別に取得する方法を採用した方がよいケースがある。性能要
    件を満たせる場合は、まとめて取得してもよい。
  * 1:Nの関係となる関連オブジェクトが、多く含まれる場合、まとめて取得すると、
    マッピング処理に使用されない無駄なデータの取得が行われ、性能劣化の原因とな
    るケースがある。性能要件を満たせる場合は、まとめて取得してもよいが、他の方
    法を検討した方がよい。

| 以降では、注文テーブルを使って、具体的に実装例について説明する。
| 説明で使用するテーブルは、以下の通りである。

 .. figure:: images/dataaccess_er.png
    :alt: ER diagram
    :width: 90%
    :align: center

    **Picture - ER diagram**

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.15\linewidth}|p{0.15\linewidth}|p{0.50\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 15 15 50

    * - 項番
      - カテゴリ
      - テーブル名
      - 説明
    * - (1)
      - トランザクション系
      - t_order
      - 注文を保持するテーブル。１つの注文に対して、1レコードが格納される。
    * - (2)
      -
      - t_order_item
      - １つの注文で購入された商品を保持するテーブル。1つの注文で、複数の商品が
        購入された場合は、商品数分レコードが格納される。
    * - (3)
      -
      - t_order_coupon
      - １つの注文で使用されたクーポンを保持するテーブル。1つの注文で、複数の
        クーポンが使用された場合は、クーポン数分レコードが格納される。クーポン
        を使用しなかった場合は、レコードは格納されない。
    * - (4)
      - マスタ系
      - m_item
      - 商品を定義するマスタテーブル。
    * - (5)
      -
      - m_category
      - カテゴリを定義するマスタテーブル。
    * - (6)
      -
      - m_item_category
      - 商品が所属するカテゴリを定義するマスタテーブル。商品とカテゴリのマッピ
        ングを保持している。1つの商品は、複数のカテゴリに属すことができるモデル
        となっている。
    * - (7)
      -
      - m_coupon
      - クーポンを定義するマスタテーブル。
    * - (8)
      - コード系
      - c_order_status
      - 注文ステータスを定義するコードテーブル。


| トランザクション系テーブルのレイアウトと、格納されているレコードは、
  以下の通りである。

 **t_order**

 .. tabularcolumns:: |p{0.20\linewidth}|p{0.20\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 20 20

    * - id(PK)
      - status_code
    * - 1
      - accepted
    * - 2
      - checking

 **t_order_item**

 .. tabularcolumns:: |p{0.20\linewidth}|p{0.20\linewidth}|p{0.20\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 20 20 20

    * - order_id(PK)
      - item_code(PK)
      - quantity
    * - 1
      - ITM0000001
      - 10
    * - 1
      - ITM0000002
      - 20
    * - 2
      - ITM0000001
      - 30
    * - 2
      - ITM0000002
      - 40


 **t_order_coupon**

 .. tabularcolumns:: |p{0.20\linewidth}|p{0.20\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 20 20

    * - order_id(PK)
      - coupon_code(PK)
    * - 1
      - CPN0000001
    * - 1
      - CPN0000002

| マスタ系テーブルのレイアウトと、格納されているレコードは、以下の通りである。

 **m_item**

 .. tabularcolumns:: |p{0.20\linewidth}|p{0.20\linewidth}|p{0.20\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 20 20 20

    * - code(PK)
      - name
      - price
    * - ITM0000001
      - Orange juice
      - 100
    * - ITM0000002
      - NotePC
      - 100000

|

 **m_category**

 .. tabularcolumns:: |p{0.20\linewidth}|p{0.20\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 20 20

    * - code(PK)
      - name
    * - CTG0000001
      - Drink
    * - CTG0000002
      - PC
    * - CTG0000003
      - Hot selling

|

 **m_item_category**

 .. tabularcolumns:: |p{0.20\linewidth}|p{0.20\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 20 20

    * - item_code(PK)
      - category_code(PK)
    * - ITM0000001
      - CTG0000001
    * - ITM0000002
      - CTG0000002
    * - ITM0000002
      - CTG0000003

|

 **m_coupon**

 .. tabularcolumns:: |p{0.20\linewidth}|p{0.20\linewidth}|p{0.20\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 20 20 20

    * - code(PK)
      - name
      - price
    * - CPN0000001
      - Join coupon
      - 3000
    * - CPN0000002
      - PC coupon
      - 30000

| コード系テーブルのレイアウトと、格納されているレコードは、以下の通りである。

 **c_order_status**

 .. tabularcolumns:: |p{0.20\linewidth}|p{0.20\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 20 20

    * - code(PK)
      - name
    * - accepted
      - Order accepted
    * - checking
      - Stock checking
    * - shipped
      - Item Shipped

| 以降で説明する実装例では、上記テーブルに格納されているデータを、以下の
  JavaBeanにマッピングして、取得する。

 .. figure:: images/dataaccess_entity.png
    :alt: Class(JavaBean) diagram
    :width: 90%
    :align: center

    **Picture - Class(JavaBean) diagram**

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.15\linewidth}|p{0.65\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 15 65

    * - 項番
      - クラス名
      - 説明
    * - (1)
      - Order
      - t_orderテーブルの1レコードを表現するJavaBean。関連オブジェクトとして、
        \ ``OrderStatus`` \と\ ``OrderItem`` \および\ ``OrderCoupon`` \を複数保
        持する。
    * - (2)
      - OrderItem
      - t_order_itemテーブルの1レコードを表現するJavaBean。関連オブジェクトとし
        て、\ ``Item`` \を保持する。
    * - (3)
      - OrderCoupon
      - t_order_couponテーブルの1コードを表現するJavaBean。関連オブジェクトとし
        て、\ ``Coupon`` \を保持する。
    * - (4)
      - Item
      - m_itemテーブルの1コードを表現するJavaBean。関連オブジェクトとして、所属
        している\ ``Category`` \を複数保持する。\ ``Item`` \と\ ``Category`` \
        の紐づけは、m_item_categoryテーブルによって行われる。
    * - (5)
      - Category
      - m_categoryテーブルの1レコードを表現するJavaBean。
    * - (6)
      - Coupon
      - m_couponテーブルの1レコードを表現するJavaBean。
    * - (7)
      - OrderStatus
      - c_order_statusテーブルの1レコードを表現するJavaBean。


| JavaBeanのプロパティ定義は、以下の通りである。

- Order.java

 .. code-block:: java

    public class Order implements Serializable {
        private int id;
        private List<OrderItem> orderItemList;
        private List<OrderCoupon> orderCouponList;
        private OrderStatus status;
    }

- OrderItem.java

 .. code-block:: java

    public class OrderItem implements Serializable {
        private int orderId;
        // (1)
        private String itemCode;
        private Item item;
        private int quantity;
    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - 保持する値が、直後の変数\ ``item`` \の\ ``code`` \プロパティと重複す
        る。これは、後述するresultMap要素の、id要素によるレコードの、グルーピン
        グを行う際に必要になるため、定義している。

- OrderCoupon.java

 .. code-block:: java

    public class OrderCoupon implements Serializable {
        private int orderId;
        // (1)
        private String couponCode;
        private Coupon coupon;
    }

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - 保持する値が、直後の変数\ ``Coupon`` \の\ ``code`` \プロパティと重複す
        る。これは、後述するresultMap要素の、id要素によるレコードの、グルーピン
        グを行う際に必要になるため、定義している。

- Item.java

 .. code-block:: java

    public class Item implements Serializable {
        private String code;
        private String name;
        private int price;
        private List<Category> categoryList;
    }

- Category.java

 .. code-block:: java

    public class Category implements Serializable {
        private String code;
        private String name;
    }

- Coupon.java

 .. code-block:: java

    public class Coupon implements Serializable {
        private String code;
        private String name;
        private int price;
    }

- OrderStatus.java

 .. code-block:: java

    public class OrderStatus implements Serializable {
        private String code;
        private String name;
    }


| SQLマッピングを実装する。
| 関連するオブジェクトを、1回のSQLでまとめて取得する場合、取得したいテーブルを
  JOINして、マッピングに必要なすべてのレコードを取得する。
| 取得したレコードは、resultMap要素にマッピング定義を行い、JavaBeanにマッピング
  する。

| 以下では、1件のOrderを取得するSQL(findOne)と、すべてのOrderを取得する
  SQL(findAll)の実装例となっている。

| 共通SQL定義は以下の通り

- XxxRepository.xml

 .. code-block:: xml

    <!-- (1) -->
    <sql id="selectFormJoin">
      <!-- (2) -->
      SELECT
        o.id AS order_id,
        os.code AS status_code,
        os.name AS status_name,
        oi.quantity,
        i.code AS item_code,
        i.name AS item_name,
        i.price AS item_price,
        ct.code AS category_code,
        ct.name AS category_name,
        cp.code AS coupon_code,
        cp.name AS coupon_name,
        cp.price AS coupon_price
      FROM
        t_order o
      <!-- (3) -->
      INNER JOIN
        c_order_status os
          ON os.code = o.status_code
      INNER JOIN
        t_order_item oi
          ON oi.order_id = o.id
      INNER JOIN
        m_item i
          ON i.code = oi.item_code
      INNER JOIN
        m_item_category ic
          ON ic.item_code = i.code
      INNER JOIN
        m_category ct
          ON ct.code = ic.category_code
      <!-- (4) -->
      LEFT JOIN
        t_order_coupon oc
          ON oc.order_id = o.id
      LEFT JOIN
        m_coupon cp
          ON cp.code = oc.coupon_code
    </sql>

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - findOneと、findAllでSELECT句、FROM句、JOIN句を共有するためのsql要素。
        findOneとfindAllで、多くの共通部分があったので共通化している。
    * - (2)
      - 関連オブジェクトを生成するために、必要なデータをすべて取得する。カラム
        名は、重複しないようにする必要がある。上記例では、\ ``code`` \,
        \ ``name`` \, \ ``price`` \が重複するため、AS句で別名を指定している。
    * - (3)
      - 関連オブジェクトを生成するために、必要なデータが格納されているテーブル
        を結合する。
    * - (4)
      - データが格納されない可能性のあるテーブルについては、外部結合とする。
        クーポンを使用しない場合、t_group_couponにレコードが格納されないので外
        部結合にする必要がある。t_group_couponと結合するt_couponも同様である。


１件取得SQL定義は以下の通り。

- XxxRepository.xml

 .. code-block:: xml

    <!-- (1) -->
    <select id="findOne"
        parameterType="int" resultMap="orderResultMap">
      <!-- (2) -->
      <include refid="selectFormJoin"/>
      WHERE
        <!-- (3) -->
        o.id = #{id}
      <!-- (4) -->
      ORDER BY
        <!-- (5) -->
        item_code ASC,
        <!-- (6) -->
        category_code ASC,
        <!-- (7) -->
        coupon_code ASC
    </select>

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - 指定された注文IDの、\ ``Order`` \オブジェクトおよび関連オブジェクトを取
        得するためのSQL。
    * - (2)
      - findAllと共有するSELECT句、FROM句、JOIN句が実装されたSQLを、インクルー
        ドしている。
    * - (3)
      - バインド値で渡された注文IDを、WHERE句に指定する。
    * - (4)
      - 1:Nの関係の関連オブジェクトがある場合は、リスト内の並び順を制御するため
        の、ORDER BY句を指定する。並び順を意識する必要がない場合は、指定は不要
        である。
    * - (5)
      - \ ``Order#orderItems`` \のリストを、t_itemテーブルのcodeカラムの昇順に
        するための指定。
    * - (6)
      - \ ``Item#categories`` \のリストを、t_categoryテーブルのcodeカラムの昇順
        にするための指定。
    * - (7)
      - \ ``Order#orderCoupons`` \のリストを、t_couponのcodeの昇順にするための
        指定。


全件取得SQL定義は以下の通り。

- findAllのSQL定義

 .. code-block:: xml

    <!-- (1) -->
    <select id="findAll" resultMap="orderResultMap">
        <!-- (2) -->
        <include refid="fragment_selectFormJoin"/>
      ORDER BY
        <!-- (3) -->
        order_id DESC,
        item_code ASC,
        category_code ASC,
        coupon_code ASC
    </select>

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - すべてのOrder、および、関連オブジェクトを取得するためのSQL。
    * - (2)
      - findOneとfindAllでSELECT句、FROM句、JOIN句を共有するためのsql要素。
    * - (3)
      - 取得されるリストの並び順を、t_orderのidの降順にするための指定。


| 上記SQL(findAll)を実行した結果、以下のレコードが取得される。
| 注文レコードとしては2件だが、レコードが複数件格納される関連テーブルと結合して
  いるため、合計で9レコードが取得される。
| 1～3行目は、注文IDが\ ``2`` \の\ ``Order`` \オブジェクトを生成するためのレ
  コード、4～9行目は注文IDが\ ``1`` \の\ ``Order`` \オブジェクトを生成するため
  のレコードとなる。

 .. figure:: images/dataaccess_sql_result.png
    :alt: Result Set of findAll
    :width: 100%
    :align: center

    **Picture - Result Set of findAll**


| 上記レコードを、\ ``Order`` \オブジェクト、および、関連オブジェクトにマッピン
  グする方法について説明する。

 .. code-block:: xml

    <resultMap id="orderResultMap" type="Order">
        <id property="id" column="order_id" />
        <association property="status" resultMap="orderStatusResultMap" />
        <collection property="orderItems" resultMap="orderItemResultMap" />
        <collection property="orderCoupons" resultMap="orderCouponResultMap" />
    </resultMap>

    <resultMap id="orderStatusResultMap" type="OrderStatus">
        <id property="code" column="status_code" />
        <result property="name" column="status_name" />
    </resultMap>

    <resultMap id="orderItemResultMap" type="OrderItem">
        <id property="itemCode" column="item_code" />
        <result property="quantity" column="quantity" />
        <association property="item" resultMap="itemResultMap" />
    </resultMap>

    <resultMap id="itemResultMap" type="Item">
        <id property="code" column="item_code" />
        <result property="name" column="item_name" />
        <result property="price" column="item_price" />
        <collection property="categoryList" resultMap="categoryResultMap" />
    </resultMap>

    <resultMap id="categoryResultMap" type="Category">
        <id property="code" column="category_code" />
        <result property="name" column="category_name" />
    </resultMap>

    <resultMap id="orderCouponResultMap" type="OrderCoupon">
        <id property="couponCode" column="coupon_code" />
        <association property="coupon" resultMap="couponResultMap" />
    </resultMap>

    <resultMap id="couponResultMap" type="Coupon">
        <id property="code" column="coupon_code" />
        <result property="name" column="coupon_name" />
        <result property="price" column="coupon_price" />
    </resultMap>

| 各resultMap要素の役割と依存関係を、以下に示す。

 .. figure:: images/dataaccess_resultmap.png
    :alt: Implementation of ResultMap
    :width: 100%
    :align: center

    **Picture - Implementation of ResultMap**

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - 取得したレコードを\ ``Order`` \オブジェクトにマッピングするための定義。
        関連オブジェクト(\ ``OrderStatus`` \, \ ``OrderItem`` \,
        \ ``OrderCoupon`` \)のマッピングは、別のresultMapに委譲している。
    * - (2)
      - 取得したレコードを、\ ``OrderStatus`` \オブジェクトにマッピングするため
        の定義。
    * - (3)
      - 取得したレコードを、\ ``OrderItem`` \オブジェクトにマッピングするための
        定義。
        関連オブジェクト(\ ``Item`` \)のマッピングは別のresultMapに委譲してい
        る。
    * - (4)
      - 取得したレコードを、\ ``Item`` \オブジェクトにマッピングするための定
        義。関連オブジェクト(\ ``Category`` \)のマッピングは、別のresultMapに委
        譲している。
    * - (5)
      - 取得したレコードを、\ ``Category`` \オブジェクトにマッピングするための
        定義。
    * - (6)
      - 取得したレコードを、\ ``OrderCoupon`` \オブジェクトにマッピングするため
        の定義。関連オブジェクト(\ ``Coupon`` \)のマッピングは、別のresultMapに
        委譲している。
    * - (7)
      - 取得したレコードを、\ ``Coupon`` \オブジェクトにマッピングするための定
        義。


| \ ``Order`` \オブジェクトへのマッピングを行う。

 .. code-block:: xml

    <resultMap id="orderResultMap" type="Order">
        <!-- (1) -->
        <id property="id" column="id" />
        <!-- (2) -->
        <association property="status"
            resultMap="orderStatusResultMap" />
        <!-- (3) -->
        <collection property="orderItemList"
            resultMap="orderItemResultMap" />
        <!-- (4) -->
        <collection property="orderCouponList"
            resultMap="orderCouponResultMap" />
    </resultMap>

 .. figure:: images/dataaccess_resultmap_order.png
    :alt: ResultMap for Order
    :width: 100%
    :align: center

    **Picture - ResultMap for Order**

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - 取得したレコードの\ ``id`` \カラムの値を、\ ``Order#id`` \に設定する。
        id要素を使用する事で、\ ``id`` \プロパティでグループ化されるため、
        \ ``id=1`` \と\ ``id=2`` \の２つの\ ``Order`` \オブジェクトが、生成され
        る。
    * - (2)
      - \ ``OrderStatus`` \ オブジェクトの生成を、
        \ ``id="order.orderStatusResultMap"`` \のresultMapに委譲し、生成された
        オブジェクトを、\ ``Order#status`` \に設定する。resultMapにオブジェクト
        の生成を委譲し、かつオブジェクトがコレクションではない場合はassociation
        要素を使用する。
    * - (3)
      - \ ``OrderItem`` \オブジェクトの生成を、
        \ ``id="order.orderItemResultMap"`` \のresultMapに委譲し、生成されたオ
        ブジェクトを、\ ``Order#orderItems`` \のリストに追加する。resultMapにオ
        ブジェクトの生成を委譲し、かつオブジェクトがコレクションである場合は
        collection要素を使用する。
    * - (4)
      - \ ``OrderCoupon`` \オブジェクトの生成を、
        \ ``id="order.orderCouponResultMap"`` \のresultMapに委譲し、生成された
        オブジェクトを、\ ``Order#orderCoupons`` \のリストに追加する。resultMap
        にオブジェクトの生成を委譲し、かつオブジェクトがコレクションである場合
        はcollection要素を使用する。

| 以降では、\ ``id=1`` \の\ ``Order`` \オブジェクトへのマッピングに、焦点を当て
  て説明する。

\ ``OrderStatus`` \オブジェクトへのマッピングを行う。

 .. code-block:: xml

    <resultMap id="orderStatusResultMap" type="OrderStatus">
        <!-- (1) -->
        <result property="code" column="status_code" />
        <!-- (2) -->
        <result property="name" column="status_name" />
    </resultMap>

 .. figure:: images/dataaccess_resultmap_orderstatus.png
    :alt: ResultMap for OrderStatus
    :width: 100%
    :align: center

    **Picture - ResultMap for OrderStatus**

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - 取得したレコードの、\ ``status_code`` \カラムの値を、
        \ ``OrderStatus#code`` \に設定する。\  ``Order`` \と、
        \ ``OrderStatus`` \オブジェクトは、1:1の関係なので、id要素を使用する。
        本例では、\ ``code=accepted`` \の\ ``OrderStatus`` \オブジェクトが生成
        される。
    * - (2)
      - 取得したレコードの、\ ``status_name`` \カラムの値を、
        \ ``OrderStatus#name`` \に設定する。


| \ ``OrderItem`` \オブジェクトへのマッピングを行う。

 .. code-block:: xml

    <resultMap id="orderItemResultMap" type="OrderItem">
        <!-- (1) -->
        <id property="itemCode" column="item_code" />
        <!-- (2) -->
        <result property="quantity" column="quantity" />
        <!-- (3) -->
        <association property="item" resultMap="itemResultMap" />
    </resultMap>

 .. figure:: images/dataaccess_resultmap_orderitem.png
    :alt: ResultMap for OrderItem
    :width: 100%
    :align: center

    **Picture - ResultMap for OrderItem**

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - 取得したレコードの\ ``item_code`` \カラムの値を、
        \ ``OrderItem#itemCode`` \に設定する。\ ``Order`` \と\ ``OrderItem`` \
        は、1:Nの関係なので、id要素を使用する。本例では、\ ``itemCode`` \プロパ
        ティでグループ化されるため、\ ``itemCode=ITM0000001`` \と
        \ ``itemCode=ITM0000002`` \の、２つの\ ``OrderItem`` \オブジェクトが生
        成される。注文商品は、t_order_itemのプライマリキー(order_id,item_code)
        でグループ化する必要があるが、order_idカラムについては、親のresultMapで
        指定されているため、ここでは、item_codeカラムの値を保持する
        \ ``itemCode`` \プロパティのみ指定する。(3)で生成される\ ``Item#code`` \
        と重複するが、\ ``itemCode`` \プロパティは、\ ``OrderItem`` \をグループ
        化するために必要なプロパティとなる。
    * - (2)
      - 取得したレコードの\ ``quantity`` \カラムの値を、
        \ ``OrderItem#quantity`` \に設定する。
    * - (3)
      - \ ``Item`` \オブジェクトの生成を、\ ``id="order.itemResultMap"`` \の
        resultMapに委譲し、生成されたオブジェクトを\ ``OrderItem#item`` \に設定
        する。

| \ ``Item`` \オブジェクトへのマッピングを行う。

 .. code-block:: xml

    <resultMap id="itemResultMap" type="Item">
        <!-- (1) -->
        <id property="code" column="item_code" />
        <!-- (2) -->
        <result property="name" column="item_name" />
        <!-- (3) -->
        <result property="price" column="item_price" />
        <!-- (4) -->
        <collection property="categoryList" resultMap="categoryResultMap" />
    </resultMap>

 .. figure:: images/dataaccess_resultmap_item.png
    :alt: ResultMap for Item
    :width: 100%
    :align: center

    **Picture - ResultMap for Item**

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - 取得したレコードの\ ``item_code`` \カラムの値を、\ ``Item#code`` \に設
        定する。\  ``OrderItem`` \と\ ``Item`` \オブジェクトは、1:1の関係だ
        が、\ ``Item`` \と\ ``Category`` \は、1:Nの関係なので、id要素を使用す
        る。カテゴリは商品毎にグループ化する必要があるため、商品を一意に識別す
        るための値が格納されている\ ``code`` \プロパティを、groupBy属性に指定す
        る。本例では、\ ``OrderItem#itemCode=ITM0000001`` \用に、
        \ ``code=ITM0000001`` \の\ ``Item`` \オブジェクトが、
        \ ``OrderItem#itemCode=ITM0000002`` \用に、\ ``code=ITM0000002`` \の
        \ ``Item`` \オブジェクトが生成される。(計２つのオブジェクトが生成され
        る。)
    * - (2)
      - 取得したレコードの\ ``item_name`` \カラムの値を、\ ``Item#name`` \に設
        定する。
    * - (3)
      - 取得したレコードの\ ``item_price`` \カラムの値を、\ ``Item#price`` \に
        設定する。
    * - (4)
      - \ ``Category`` \オブジェクトの生成を、\ ``id="categoryResultMap"`` \の
        resultMapに委譲し、生成されたオブジェクトを ``Item#categoryList`` のリ
        ストに追加する。格納するプロパティがコレクションであるためcollection要
        素を使用する。


| \ ``Category`` \オブジェクトへのマッピングを行う。

 .. code-block:: xml

    <resultMap id="categoryResultMap" type="Category">
        <!-- (1) -->
        <id property="code" column="category_code" />
        <!-- (2) -->
        <result property="name" column="category_name" />
    </resultMap>

 .. figure:: images/dataaccess_resultmap_category.png
    :alt: ResultMap for Item
    :width: 100%
    :align: center

    **Picture - ResultMap for Item**

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - 取得したレコードの \ ``item_code`` \カラムの値を、\ ``Item#code`` \に設
        定する。本例では、1:Nの関係のテーブル(t_orderとt_order_line、t_orderと
        t_order_coupon)を複数結合しているため、t_order_couponに複数レコードが格
        納されていると \ ``Item`` \オブジェクト内に保持する\ ``Category`` \オブ
        ジェクトのリストが、重複してしまう。重複をなくすために、カテゴリを一意
        に識別する値が格納されている\ ``code`` \プロパティを、id要素で指定す
        る。\ ``code`` \プロパティの値が、同じ\ ``Category`` \オブジェクトが一
        つにマージされ、重複をなくすことができる。本例では、
        \ ``Item#code=ITM0000001`` \用に、\ ``code=CTG0000001`` \の
        \ ``Category`` \オブジェクトが、\ ``Item#code=ITM0000002`` \用に、
        \ ``code=CTG0000002`` \と、\ ``code=CTG0000003`` \の2つの
        \ ``Category`` \オブジェクトが生成される。(計3つのオブジェクトが生成さ
        れる。)
    * - (2)
      - 取得したレコードの \ ``item_name`` \カラムの値を、\ ``Item#name`` \に設
        定する。


| \ ``OrderCoupon`` \オブジェクトへのマッピングを行う。

 .. code-block:: xml

    <resultMap id="orderCouponResultMap" type="OrderCoupon">
        <!-- (1) -->
        <id property="couponCode" column="coupon_code" />
        <!-- (2) -->
        <association property="coupon" resultMap="couponResultMap" />
    </resultMap>

 .. figure:: images/dataaccess_resultmap_ordercoupon.png
    :alt: ResultMap for OrderCoupon
    :width: 100%
    :align: center

    **Picture - ResultMap for OrderCoupon**

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - 取得したレコードの\ ``coupon_code`` \カラムの値を、
        \ ``OrderCoupon#couponCode`` \に設定する。\  ``Order`` \と
        \ ``OrderCoupon`` \は、1:Nの関係なので、id要素を使用する。(2)で生成され
        る\ ``Coupon#code`` \と重複するが、\ ``couponCode`` \プロパティは、
        \ ``OrderCoupon`` \をグループ化するために必要なプロパティとなる。本例で
        は、\ ``couponCode`` \プロパティでグループ化されるため、
        \ ``couponCode=CPN0000001`` \と\ ``couponCode=CPN0000002`` \の2つの
        \ ``OrderCoupon`` \オブジェクトが生成される。注文クーポンは、
        t_order_couponのプライマリキー(order_id,coupon_code)でグループ化する必
        要があるが、order_idカラムについては親のresultMapで指定されているため、
        ここでは、coupon_codeカラムの値を保持する\ ``couponCode`` \プロパティの
        み指定する。
    * - (2)
      - \ ``Coupon`` \オブジェクトの生成を\ ``id="couponResultMap"`` \の
        resultMapに委譲し、生成されたオブジェクトを\ ``OrderCoupon#coupon`` \に
        設定する。


| \ ``Coupon`` \オブジェクトへのマッピングを行う。

 .. code-block:: xml

    <resultMap id="couponResultMap" type="Coupon">
        <!-- (1) -->
        <result property="code" column="coupon_code" />
        <!-- (2) -->
        <result property="name" column="coupon_name" />
        <!-- (3) -->
        <result property="price" column="coupon_price" />
    </resultMap>

 .. figure:: images/dataaccess_resultmap_coupon.png
    :alt: ResultMap for Coupon
    :width: 100%
    :align: center

    **Picture - ResultMap for Coupon**

 .. tabularcolumns:: |p{0.10\linewidth}|p{0.80\linewidth}|
 .. list-table::
    :header-rows: 1
    :widths: 10 80

    * - 項番
      - 説明
    * - (1)
      - 取得したレコードの\ ``coupon_code`` \カラムの値を、\ ``Coupon#code`` \
        に設定する。\ ``OrderCoupon`` \と\ ``Coupon`` \オブジェクトは、1:1の関
        係なので、result要素を使用する。本例では、
        \ ``OrderCoupon#couponCode=CPN0000001`` \用に、\ ``code=CPN0000001`` \の
        \ ``Coupon`` \オブジェクトが、\ ``OrderCoupon#couponCode=CPN0000001`` \
        用に、\ ``code=CPN0000001`` \の\ ``Coupon`` \オブジェクトが生成される。
        (計２つのオブジェクトが生成される。)
    * - (2)
      - 取得したレコードの\ ``coupon_name`` \カラムの値を、\ ``Coupon#name`` \
        に設定する。
    * - (3)
      - 取得したレコードの\ ``coupon_price`` \ カラムの値を、\ ``Coupon#price`` \
        に設定する。


| JavaBeanにマッピングされたレコードとカラムは、以下の通りである。
| グレーアウトしている部分は、groupBy属性に指定によって、グレーアウトされていな
  い部分にマージされる。

 .. figure:: images/dataaccess_sql_result_used.png
    :alt: Valid Result Set for result mapping
    :width: 100%
    :align: center

    **Picture - Valid Result Set for result mapping**


.. _data-access-mybatis2_warning_sqlmapping_bulk:

 .. warning::

     1:Nの関連をもつレコードをJOINしてマッピングする場合、グレーアウトされてい
     る部分のデータの取得が無駄になる点を、意識しておくこと。

     Nの部分のデータを使用しない処理で、同じSQLを使用した場合、さらに無駄なデー
     タの取得となってしまうので、Nの部分を取得するSQLと、取得しないSQLを、別々
     に用意しておくなどの工夫を行うこと。


| 実際にマッピングされた\ ``Order`` \オブジェクトおよび関連オブジェクトの状態
  は、以下の通りである。

 .. figure:: images/dataaccess_object.png
    :alt: Mapped object diagram
    :width: 90%
    :align: center

    **Picture - Mapped object diagram**

 .. tip::

     関連オブジェクトを取得する別の方法として、取得したレコードの値を使って、内
     部で別のSQLを実行して、取得する方法がある。内部で別のSQLを実行する方法は、
     個々のSQLや、resultMap要素の定義が、非常にシンプルとなる。ただし、この方法
     で取得する場合は、N+1問題を引き起こす要因となることを、意識しておく必要が
     ある。


 .. tip::

     内部で別のSQLを実行する方法を使う場合、関連オブジェクトは "Eager Load"され
     るため、関連オブジェクトを使用しない場合も、SQLが実行されてしまう。この動
     作回避する方法として、Mybatisでは、関連オブジェクトを "Lazy Load"する方法
     を、オプションとして提供している。

     "Lazy Load"を有効にするための設定は、以下の通りである。

     * CGLIBをクラスパスに追加する。
     * Mybatis設定ファイルのsetting要素のlazyLoadingEnabled属性を、
       \ ``true`` \に設定する。

      .. code-block:: xml

         <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
         <project xmlns="http://maven.apache.org/POM/4.0.0"
             xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
             xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
                 http://maven.apache.org/maven-v4_0_0.xsd">

             <dependencyManagement>
                 <dependencies>
                     <dependency>
                         <groupId>cglib</groupId>
                         <artifactId>cglib</artifactId>
                         <version>${cglib.version}</version>
                     </dependency>
                 </dependencies>
             </dependencyManagement>

             <properties>
                 <cglib.version>2.2</cglib.version>
             </properties>

         </project>

      .. code-block:: xml

         <?xml version="1.0" encoding="UTF-8" ?>
         <!DOCTYPE configuration PUBLIC "-//mybatis.org/DTD Config 3.0//EN"
             "http://mybatis.org/dtd/mybatis-3-config.dtd">
         <configuration>

             <settings>
                 <setting name="lazyLoadingEnabled" value="true" />
             </settings>

         </configuration>


.. raw:: latex

   \newpage

