Feature: Boards put tests

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

  Scenario: Update board an existing board by id
    Given path 'boards/' + idCreatedBoard
    And param name = 'Updated name'
    And param desc = 'New description for a board'
    And param closed = true
    And param prefs/permissionLevel = 'private'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    And request ''
    When method put
    Then status 200
    And match response.name == 'Updated name'
    And match response.desc == 'New description for a board'
    And match response.closed == true
    And match response.prefs.permissionLevel == 'private'
    And print response

  Scenario: Update an existing board by id and add new user by add mail address
    * def username = org.apache.commons.lang.RandomStringUtils.randomAlphabetic(10).toLowerCase()
    * def mailProvider = '@' + org.apache.commons.lang.RandomStringUtils.randomAlphabetic(10) + '.com'
    * def fullMail = username + mailProvider

    * def jsonBody =
    """
    {"fullName":"ADDED_USER_NAME_BY_UPDATED_BOARD"}
    """

    * def jsonMatch =
    """
    {
      "id": #string,
      "fullName": #(username),
    }
    """

    Given path 'boards/' + idCreatedBoard + '/members'
    And param email = fullMail
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    And header Content-Type = 'application/json'
    And request json
    When method put
    Then status 200
    And match response.id == idCreatedBoard
    And match response.members[*].fullName contains any username
    And match response.members[*].fullName contains any 'trelloautoapitest'
    And print response
    And print jsonMatch

  Scenario: Add a member to the board.

    * def jsonMatch =
    """
    {
      "id": "5e31b359cd8dfc1384b2e515",
      "activityBlocked": false,
      "avatarHash": null,
      "avatarUrl": null,
      "fullName": "trelloautoapitest2",
      "idMemberReferrer": null,
      "initials": "T",
      "nonPublic": {
      },
      "nonPublicAvailable": true,
      "username": "userautoapitest2",
      "confirmed": true,
      "memberType": "normal"
    }
    """
    * def idMember = '5e31b359cd8dfc1384b2e515'
    Given path 'boards/' + idCreatedBoard + '/members/' + idMember
    And param type = 'normal'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    And request ''
    When method put
    Then status 200
    And match response.members contains jsonMatch
    And print response

  Scenario: Update an existing board by id and add membership to a board

    * def idMember = '5e31b359cd8dfc1384b2e515'
    Given path 'boards/' + idCreatedBoard + '/members/' + idMember
    And param type = 'normal'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    And request ''
    When method put
    Then status 200
    And print response

    Given path '/boards/' + idCreatedBoard + '/memberships'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200
    And print response

    * def json = response;
    * def idMembership = get json[1].id

    Given path 'boards/' + idCreatedBoard + '/memberships/' + idMembership
    And param type = 'admin'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    And request ''
    When method put
    Then status 200
    And match response.id == idMembership
    And match response.memberType == 'admin'
    And match response.idMember == idMember
    And print response

  Scenario: Update a board email position on bottom in prefs

    * def jsonMatch =
    """
  {
  "showSidebar": #boolean,
  "showSidebarMembers": #boolean,
  "showSidebarBoardActions": #boolean,
  "showSidebarActivity": #boolean,
  "showListGuide": #boolean,
  "idEmailList": null,
  "emailPosition": "bottom"
  }
    """
    Given path 'boards/' + idCreatedBoard + '/myPrefs/emailPosition'
    And param value = 'bottom'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    And request ''
    When method put
    Then status 200
    And print response
    And match response contains jsonMatch

  Scenario: Update a board email list id in prefs
    # Generate email list key
    Given path 'boards/' + idCreatedBoard + '/emailKey/generate'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    And request ''
    When method post
    Then status 200
    And print response

    * def json = response
    * def idEmailList = json.myPrefs.idEmailList

    Given path 'boards/' + idCreatedBoard + '/myPrefs/idEmailList'
    And param value = idEmailList
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    And request ''
    When method put
    Then status 200
    And match response.idEmailList == idEmailList
    And print response

  Scenario: Update a board show list guide in prefs

    Given path 'boards/' + idCreatedBoard + '/myPrefs/showListGuide'
    And param value = false
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    And request ''
    When method put
    Then status 200
    And match response.showListGuide == false
    And print response

  Scenario: Update a board show sidebar in prefs

    Given path 'boards/' + idCreatedBoard + '/myPrefs/showSidebar'
    And param value = false
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    And request ''
    When method put
    Then status 200
    And match response.showSidebar == false
    And print response

  Scenario: Update a board show sidebar activity in prefs

    Given path 'boards/' + idCreatedBoard + '/myPrefs/showSidebarActivity'
    And param value = false
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    And request ''
    When method put
    Then status 200
    And match response.showSidebarActivity == false
    And print response

  Scenario: Update a board show sidebar board actions in prefs

    Given path 'boards/' + idCreatedBoard + '/myPrefs/showSidebarBoardActions'
    And param value = false
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    And request ''
    When method put
    Then status 200
    And match response.showSidebarBoardActions == false
    And print response

  Scenario: Update a board show sidebar members in prefs

    Given path 'boards/' + idCreatedBoard + '/myPrefs/showSidebarMembers'
    And param value = false
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    And request ''
    When method put
    Then status 200
    And match response.showSidebarMembers == false
    And print response
