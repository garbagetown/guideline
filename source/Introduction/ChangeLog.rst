更新履歴
================================================================================


.. tabularcolumns:: |p{0.15\linewidth}|p{0.25\linewidth}|p{0.60\linewidth}|
.. list-table::
    :header-rows: 1
    :widths: 15 25 60

    * - 更新日付
      - 改訂箇所
      - 改訂内容
    * - 2014-05-01
      - \-
      - 1.0.1.RELEASE版公開
        
        改訂内容の詳細は、\ `1.0.1のIssue一覧 <https://github.com/terasolunaorg/guideline/issues?labels=&milestone=1&state=closed>`_\ を参照されたい。
    * - 
      - 全般
      - ガイドラインのバグ(タイプミスや記述ミス)を修正

        改訂内容の詳細は、\ `1.0.1のBug一覧 <https://github.com/terasolunaorg/guideline/issues?labels=bug&milestone=1&state=closed>`_\ を参照されたい。
    * - 
      - 日本語版
      - 以下の日本語版を追加
      
        * :doc:`CriteriaBasedMapping`
        * :doc:`../ArchitectureInDetail/REST`
        * :doc:`../TutorialREST/index`
    * - 
      - 英語版
      - 以下の英語版を追加
      
        * :doc:`index`
        * :doc:`../Overview/index`
        * :doc:`../TutorialTodo/index`
        * :doc:`../ImplementationAtEachLayer/index`
        * :doc:`../ArchitectureInDetail/Validation`
    * - 
      - :doc:`../Overview/FrameworkStack`
      - バグ改修に伴うOSSのバージョンのバージョンアップを反映
      
        * GroupId「\ ``org.springframework``\」のバージョンを3.2.4.RELEASEから3.2.8.RELEASEに更新
        * ArtifactId「\ ``spring-data-commons``\」のバージョンを1.6.1.RELEASEから1.6.4.RELEASEに更新
        * ArtifactId「\ ``spring-data-jpa``\」のバージョンを1.4.1.RELEASEから1.4.3.RELEASEに更新
    * - 
      - :doc:`../ImplementationAtEachLayer/ApplicationLayer`
      - `CVE-2014-1904 <http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2014-1904>`_\(\ ``<form:form>``\タグのaction属性のXSS脆弱性)に関する注意喚起を追記
    * - 
      - :doc:`../ArchitectureInDetail/MessageManagement`
      - 以下のバグ改修に関する記載を追加
      
        * 共通ライブラリから提供している\ ``<t:messagesPanel>``\タグのバグ改修(\ `terasoluna-gfw#10 <https://github.com/terasolunaorg/terasoluna-gfw/issues/10>`_\)に関する記載を更新
    * - 
      - :doc:`../ArchitectureInDetail/Pagination`
      - 以下のバグ改修に関する記載を更新
      
        * \ ``<t:pagination>``\タグのバグ改修(\ `terasoluna-gfw#12 <https://github.com/terasolunaorg/terasoluna-gfw/issues/12>`_\)に関する記載を更新
        * Spring Data Commonsのバグ改修(\ `terasoluna-gfw#22 <https://github.com/terasolunaorg/terasoluna-gfw/issues/22>`_\)に関する記載を更新
    * - 
      - :doc:`../ArchitectureInDetail/Ajax`
      - XXE Injection対策に関する記載を更新
    * - 
      - :doc:`../ArchitectureInDetail/FileUpload`
      - `CVE-2014-0050 <http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2014-0050>`_\(File Uploadの脆弱性)に関する注意喚起を追記
    * - 2013-12-17
      - 日本語版
      - Public Review版公開

.. raw:: latex

   \newpage

