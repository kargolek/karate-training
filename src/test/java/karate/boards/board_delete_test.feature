Feature: Boards delete tests

  Background:
    * url baseUrl
    * call read('backgrounds_board.feature')

  Scenario: Delete a board.
    Given path '/boards/' + idCreatedBoard
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    When method delete
    Then status 200
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