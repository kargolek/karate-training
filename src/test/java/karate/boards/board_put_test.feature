Feature: Boards put tests

  Background:
    * url 'https://api.trello.com/1/'
    * call read('backgrounds_board.feature')

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

  Scenario: Update an existing board by id and add new user by add mail address
    * def username = org.apache.commons.lang.RandomStringUtils.randomAlphabetic(10).toLowerCase()
    * def mailProvider = '@' + org.apache.commons.lang.RandomStringUtils.randomAlphabetic(10) + '.com'
    * def fullMail = username + mailProvider

    Given path 'boards/' + idCreatedBoard + '/members'
    And param email = fullMail
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    And header Content-Type = 'application/json'
    And request ''
    When method put
    Then status 200
    And match response.id == idCreatedBoard
    And match response.members[*].fullName contains any username
    And match response.members[*].fullName contains any 'trelloautoapitest'

  Scenario: Add a member to the board.
    * def idMember = '5e31b359cd8dfc1384b2e515'
    Given path 'boards/' + idCreatedBoard + '/members/' + idMember
    And param type = 'normal'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    And request ''
    When method put
    Then status 200
    And match response.members contains
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

  Scenario: Update an existing board by id and add membership to a board
    * def idMember = '5e31b359cd8dfc1384b2e515'
    Given path 'boards/' + idCreatedBoard + '/members/' + idMember
    And param type = 'normal'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    And request ''
    When method put
    Then status 200

    Given path '/boards/' + idCreatedBoard + '/memberships'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200

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

  Scenario: Update a board email position on bottom in prefs
    Given path 'boards/' + idCreatedBoard + '/myPrefs/emailPosition'
    And param value = 'bottom'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    And request ''
    When method put
    Then status 200
    And print response
    And match response contains
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

  Scenario: Update a board email list id in prefs
    # Generate email list key
    Given path 'boards/' + idCreatedBoard + '/emailKey/generate'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    And request ''
    When method post
    Then status 200

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

  Scenario: Update a board show list guide in prefs

    Given path 'boards/' + idCreatedBoard + '/myPrefs/showListGuide'
    And param value = false
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    And request ''
    When method put
    Then status 200
    And match response.showListGuide == false

  Scenario: Update a board show sidebar in prefs

    Given path 'boards/' + idCreatedBoard + '/myPrefs/showSidebar'
    And param value = false
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    And request ''
    When method put
    Then status 200
    And match response.showSidebar == false

  Scenario: Update a board show sidebar activity in prefs

    Given path 'boards/' + idCreatedBoard + '/myPrefs/showSidebarActivity'
    And param value = false
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    And request ''
    When method put
    Then status 200
    And match response.showSidebarActivity == false

  Scenario: Update a board show sidebar board actions in prefs

    Given path 'boards/' + idCreatedBoard + '/myPrefs/showSidebarBoardActions'
    And param value = false
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    And request ''
    When method put
    Then status 200
    And match response.showSidebarBoardActions == false

  Scenario: Update a board show sidebar members in prefs

    Given path 'boards/' + idCreatedBoard + '/myPrefs/showSidebarMembers'
    And param value = false
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    And request ''
    When method put
    Then status 200
    And match response.showSidebarMembers == false
