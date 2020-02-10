Feature: Boards get tests

  Background:
    * url baseUrl
    * call read('backgrounds_board.feature')

  Scenario: Request all boards data
    Given path 'members/me/boards'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200
    And match $[0].name contains '#string'

  Scenario: Request single board data
    Given path 'boards'
    Given path idCreatedBoard
    Given path 'name'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200
    And match $._value == boardNameRandom

  Scenario: Get board actions and limit record to one
    Given path 'boards'
    And path idCreatedBoard
    And path 'actions'
    And form field limit = 1
    And form field key = java.lang.System.getenv('trl_key');
    And form field token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200
    And match $[1].id == '#notpresent'
    And match $[0] contains
    """
   {
      "id":'#string',
      "idMemberCreator":'#string',
      "type":'#string',
      "date":'#string',
      "memberCreator":{
         "id":'#string',
         "activityBlocked":'#boolean',
         "avatarHash":'#null',
         "avatarUrl":'#null',
         "fullName":"trelloautoapitest",
         "idMemberReferrer":'#null',
         "initials":"T",
         "nonPublic":{},
         "nonPublicAvailable":true,
         "username":"userautoapitest"
      }
   }
    """

  Scenario: Get the enabled Power-Ups on a board
    Given path 'boards'
    And path idCreatedBoard
    And path 'boardPlugins'
    And form field key = java.lang.System.getenv('trl_key');
    And form field token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200
    And match $[0] contains
     """
    {
      "id": '#string',
      "idBoard": '#string',
      "idPlugin": '#string'
    }
      """

  Scenario: Get data of starred board
    #POST a new star on the latest created board
    Given path 'members/' +  idUsername + '/boardStars'
    And form field idBoard = idCreatedBoard
    And form field pos = 'top'
    And form field key = java.lang.System.getenv('trl_key');
    And form field token = java.lang.System.getenv('trl_token');
    When method post
    Then status 200

    #GET data of starred board action
    Given path 'boards/' + idCreatedBoard + '/boardStars'
    And form field key = java.lang.System.getenv('trl_key');
    And form field token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200
    And match $[0] contains
    """
   {
      "_id": '#string',
      "idBoard": '#string',
      "pos": '#number'
   }
    """

  Scenario: Fetch open cards on a board
    Given path 'boards/' + idCreatedBoard + '/cards'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200
    And match $[0] contains
     """
  {
    "id": '#string',
    "checkItemStates": '#null',
    "closed": '#boolean',
    "dateLastActivity": '#string',
    "desc": '#string',
    "descData": '#null',
    "idBoard": '#string',
    "idList": '#string',
    "idMembersVoted": '#array',
    "idShort": '#number',
    "idAttachmentCover": '#null',
    "manualCoverAttachment": '#boolean',
    "idLabels": '#array',
    "name": '#string',
    "pos": '#number',
    "shortLink": '#string',
    "dueComplete": '#boolean',
    "idChecklists": '#array',
    "idMembers": '#array',
    "labels": '#array',
    "shortUrl": '#string',
    "subscribed": '#boolean',
    "url": '#string'
  }
    """

  Scenario: Fetch card data by id
    Given path 'boards/' + idCreatedBoard + '/cards/' + idCreatedCard
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200
    And match $.id == idCreatedCard

  Scenario: Fetch checklists data
      #POST checklist on card
    Given path 'checklists'
    And form field idCard = idCreatedCard
    And form field name = 'new checklist name'
    And form field key = java.lang.System.getenv('trl_key');
    And form field token = java.lang.System.getenv('trl_token');
    When method post
    Then status 200

    Given path 'boards/' + idCreatedBoard + '/checklists'
    And form field key = java.lang.System.getenv('trl_key');
    And form field token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200
    And match $[0] contains
     """
  {
   "id":'#string',
   "name":"new checklist name",
   "idBoard":'#string',
   "idCard":'#string',
   "pos":'#number',
   "checkItems":'#array'
  }
    """

  Scenario: Get the Custom Field Definitions that exist on a board.
    #Enable board plugins custom fields on newly created board
    Given path 'boards/' + idCreatedBoard + '/boardPlugins'
    And form field idPlugin = idCustomFieldsPlugin
    And form field key = java.lang.System.getenv('trl_key');
    And form field token = java.lang.System.getenv('trl_token');
    When method post
    Then status 200

    #Create custom field list with two options on the board
    Given path 'customFields'
    And header Content-Type = 'application/json'
    And request
    """
   {
   "idModel":"#(idCreatedBoard)",
   "modelType":"board",
   "name":"New",
   "options":[
      {
         "color":"none",
         "value":{
            "text":"First Option"
         },
         "pos":1024
      },
      {
         "color":"none",
         "value":{
            "text":"Second Option"
         },
         "pos":2048
      }
   ],
   "type":"list",
   "pos":"top",
   "display_cardFront":true
   }
    """
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    When method post
    Then status 200

    #Get data for created custom field
    Given path 'boards/' + idCreatedBoard + '/customFields'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200
    And match $[0].id == '#string'
    And match $[0].idModel == idCreatedBoard

  Scenario: Get labels data from a board
    Given path 'boards/' + idCreatedBoard + '/labels'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200
    And match $[0] contains
    """
    {
      "id": '#string',
      "name": '#string',
      "color": '#string'
    }
      """

  Scenario: Get list date from a board
    Given path 'boards/' + idCreatedBoard + '/lists'
    And param cards = 'all'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200
    And match $[0] contains
    """
  {
    "id": '#string',
    "name": '#string',
    "cards": '#array'
  }
    """

  Scenario: Get list date from a board with filter option
    Given path '/lists/' + idFirstList + '/closed'
    And param value = true
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    And request '/lists/' + idFirstList + '/closed'
    When method put
    Then status 200

    Given path '/boards/' + idCreatedBoard + '/lists/closed'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200
    And match response[0] contains
     """
  {
    "id": '#string',
    "name": '#string',
    "closed": true,
    "idBoard": '#string',
    "pos": '#number',
    "subscribed": '#boolean'
  }
    """

  Scenario: Get the members for a board
    Given path '/boards/' + idCreatedBoard + '/members'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200
    And match response[0] ==
    """
  {
    "id": '#(idUsername)',
    "fullName": "trelloautoapitest",
    "username": "userautoapitest"
  }
    """

  Scenario: Get information about the memberships users have to the board.
    Given path '/boards/' + idCreatedBoard + '/memberships'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200
    And match response[0] ==
    """
  {
    "id": '#string',
    "idMember": '#(idUsername)',
    "memberType": "admin",
    "unconfirmed": false,
    "deactivated": false
  }
    """

  Scenario: List the Power-Ups for a board
    Given path '/boards/' + idCreatedBoard + '/plugins'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200
    And match response[0] contains
    """
  {
    "id": #string,
    "idOrganizationOwner": #string,
    "author": #string,
    "capabilities": #array,
    "categories": #array,
    "iframeConnectorUrl": #string,
    "name": #string,
  }
    """
