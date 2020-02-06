Feature: Boards delete tests

  Background:
    * url 'https://api.trello.com/1/'
    * def boardNameRandom = org.apache.commons.lang.RandomStringUtils.randomAlphabetic(10);
    #Create a board before each scenario, pass board id to idCreatedBoard field
    Given path 'boards'
    And form field name = boardNameRandom
    And form field defaultLists = 'true'
    And form field key = java.lang.System.getenv('trl_key');
    And form field token = java.lang.System.getenv('trl_token');
    When method post
    Then status 200
    And print response

    * def json = response
    * def idCreatedBoard = get json.id
    * def idUsername = '5e23b17009db88314e564927'
    * def idCustomFieldsPlugin = '56d5e249a98895a9797bebb9'
    * def idMember = '5e31b359cd8dfc1384b2e515'


    Given path 'boards/' + idCreatedBoard + '/lists'
    And form field key = java.lang.System.getenv('trl_key');
    And form field token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200
    * def jsonLists = response
    * def idFirstList = get jsonLists[0].id

    * def cardNameRandom = org.apache.commons.lang.RandomStringUtils.randomAlphabetic(10);
    Given path 'cards/'
    And form field name = cardNameRandom
    And form field idList = idFirstList
    And form field key = java.lang.System.getenv('trl_key');
    And form field token = java.lang.System.getenv('trl_token');
    When method post
    Then status 200
    * def resBody = response
    * def idCreatedCard = get resBody.id

  Scenario: Delete a board.
    Given path '/boards/' + idCreatedBoard
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    When method delete
    Then status 200
    And print response
    And match response ==
      """
      {"_value": null}
      """

  Scenario: Disable a Power-Up on a board.
    Given path '/boards/' + idCreatedBoard + '/boardPlugins'
    And param idPlugin = idCustomFieldsPlugin
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    And request ''
    When method post
    Then status 200
    And print response
    * def json = response
    * def idPluginForDisable = get json.id

    Given path '/boards/' + idCreatedBoard + '/boardPlugins/' + idPluginForDisable
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    When method delete
    Then status 200
    And print response

  Scenario: Remove user from the board.

    Given path 'boards/' + idCreatedBoard + '/members/' + idMember
    And param type = 'normal'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    And request ''
    When method put
    Then status 200

    Given path '/boards/' + idCreatedBoard + '/members/' + idMember
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    When method delete
    Then status 200
    And print response
    And match response !contains
    """
    {
      "id": "5e31b359cd8dfc1384b2e515",
      "activityBlocked": false,
      "avatarHash": null,
      "avatarUrl": null,
      "fullName": "trelloautoapitest2",
      "idMemberReferrer": null,
      "initials": "T",
      "nonPublic": #object,
      "nonPublicAvailable": true,
      "username": "userautoapitest2",
      "confirmed": true,
      "memberType": "normal"
    }
    """

  Scenario: Remove power up from a board.
    Given path 'boards/' + idCreatedBoard + '/powerUps/voting'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    When method delete
    Then status 200