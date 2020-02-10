Feature: Boards post tests

  Background:
    * url 'https://api.trello.com/1/'
    * call read('backgrounds_board.feature')

  Scenario: Create a new board.
    Given path 'boards'
    And param name = 'My new board for a test purpose'
    And param defaultLabels = false
    And param defaultLists = true
    And param desc = 'My board description'
    And param keepFromSource = 'none'
    And param powerUps = 'all'
    And param prefs_permissionLevel = 'public'
    And param prefs_voting = 'disabled'
    And param prefs_comments = 'disabled'
    And param prefs_invitations = 'admins'
    And param prefs_selfJoin = true
    And param prefs_cardCovers = false
    And param prefs_background = 'red'
    And param prefs_cardAging = 'pirate'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    And request ''
    When method post
    Then status 200
    And match response contains
    """
  {
    "id": #string,
    "name": "My new board for a test purpose",
    "desc": "My board description",
    "descData": #null,
    "closed": false,
    "idOrganization": #null,
    "idEnterprise": #null,
    "pinned": false,
    "url": #string,
    "shortUrl": #string,
    "prefs": {
      "permissionLevel": "public",
      "hideVotes": false,
      "voting": "disabled",
      "comments": "disabled",
      "invitations": "admins",
      "selfJoin": true,
      "cardCovers": false,
      "isTemplate": #boolean,
      "cardAging": "pirate",
      "calendarFeedEnabled": #boolean,
      "background": "red",
      "backgroundImage": #null,
      "backgroundImageScaled": #null,
      "backgroundTile": #boolean,
      "backgroundBrightness": #string,
      "backgroundColor": #string,
      "backgroundBottomColor": #string,
      "backgroundTopColor": #string,
      "canBePublic": true,
      "canBeEnterprise": true,
      "canBeOrg": true,
      "canBePrivate": true,
      "canInvite": true
      }
  }
      """
  Scenario: Enable a Power-Up on a board
    Given path '/boards/' + idCreatedBoard + '/boardPlugins'
    And param idPlugin = idCustomFieldsPlugin
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    And request ''
    When method post
    Then status 200
    And match response ==
     """
  {
  "id": #string,
  "idPlugin": #(idCustomFieldsPlugin),
  "idBoard": #(idCreatedBoard)
  }
    """

  Scenario: Create color label on the board
    Given path '/boards/' + idCreatedBoard + '/labels'
    And param name = 'new label'
    And param color = 'green'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    And request ''
    When method post
    Then status 200
    And match response ==
    """
  {
    "id": #string,
    "idBoard": #(idCreatedBoard),
    "name": "new label",
    "color": "green",
    "limits": #object
  }
    """

  Scenario: Create new list on board with position value
    Given path '/boards/' + idCreatedBoard + '/lists'
    And param name = 'New list created for post endpoint scenario'
    And param pos = 'top'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    And request ''
    When method post
    Then status 200
    And match response ==
    """
  {
    "id": #string,
    "name": "New list created for post endpoint scenario",
    "closed": false,
    "idBoard": #(idCreatedBoard),
    "pos": #number,
    "limits": #object
  }
    """

  Scenario: Mark the board as viewed
    Given path '/boards/' + idCreatedBoard + '/markedAsViewed'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    And request ''
    When method post
    Then status 200

  Scenario: Enable power ups on the board
    Given path '/boards/' + idCreatedBoard + '/powerUps'
    And param value = 'calendar'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    And request ''
    When method post
    Then status 410
    And match response ==
    """
   {"message":"Gone"}
    """