Feature: Boards post tests

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
    * def idCalendarPlugin = '55a5d917446f517774210011'

    Given path 'boards/' + idCreatedBoard + '/lists'
    And form field key = java.lang.System.getenv('trl_key');
    And form field token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200
    * def jsonLists = response
    * def idFirstList = get jsonLists[0].id

    * def cardNameRandom = org.apache.commons.lang.RandomStringUtils.randomAlphabetic(10);
    Given path 'cards/'
    And param name = cardNameRandom
    And param idList = idFirstList
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    And request ''
    When method post
    Then status 200
    * def resBody = response
    * def idCreatedCard = get resBody.id

  Scenario: Create a new board.

    * def jsonMatch =
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
    And print response
    And match response contains jsonMatch

  Scenario: Enable a Power-Up on a board
    * def jsonMatch =
    """
  {
  "id": #string,
  "idPlugin": #(idCustomFieldsPlugin),
  "idBoard": #(idCreatedBoard)
  }
    """
    Given path '/boards/' + idCreatedBoard + '/boardPlugins'
    And param idPlugin = idCustomFieldsPlugin
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    And request ''
    When method post
    Then status 200
    And print response
    And match response == jsonMatch

  Scenario: Create color label on the board
    * def jsonMatch =
      """
  {
    "id": #string,
    "idBoard": #(idCreatedBoard),
    "name": "new label",
    "color": "green",
    "limits": #object
  }
      """

    Given path '/boards/' + idCreatedBoard + '/labels'
    And param name = 'new label'
    And param color = 'green'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    And request ''
    When method post
    Then status 200
    And print response
    And match response == jsonMatch

  Scenario: Create new list on board with position value

    Given path '/boards/' + idCreatedBoard + '/lists'
    And param name = 'New list created for post endpoint scenario'
    And param pos = 'top'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    And request ''
    When method post
    Then status 200
    And print response
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
    And print response

  Scenario: Enable power ups on the board

    Given path '/boards/' + idCreatedBoard + '/powerUps'
    And param value = 'calendar'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    And request ''
    When method post
    Then status 410
    And print response
    And match response ==
    """
   {"message":"Gone"}
    """