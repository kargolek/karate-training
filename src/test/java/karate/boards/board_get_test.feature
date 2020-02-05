Feature: Boards get tests

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

  Scenario: Request all boards data
    Given path 'members/me/boards'
    And form field key = java.lang.System.getenv('trl_key');
    And form field token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200
    And match $[0].name contains '#string'
    And print response

  Scenario: Request single board data
    Given path 'boards'
    Given path idCreatedBoard
    Given path 'name'
    And form field key = java.lang.System.getenv('trl_key');
    And form field token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200
    And match $._value == boardNameRandom
    And print response

  Scenario: Get board actions and limit record to one
    * def responseBody =
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
    Given path 'boards'
    And path idCreatedBoard
    And path 'actions'
    And form field limit = 1
    And form field key = java.lang.System.getenv('trl_key');
    And form field token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200
    And match $[0] contains responseBody
    And match $[1].id == '#notpresent'
    And print response

  Scenario: Get the enabled Power-Ups on a board
    * def responseBody =
      """
    {
      "id": '#string',
      "idBoard": '#string',
      "idPlugin": '#string'
    }
      """
    Given path 'boards'
    And path idCreatedBoard
    And path 'boardPlugins'
    And form field key = java.lang.System.getenv('trl_key');
    And form field token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200
    And match $[0] contains responseBody
    And print response

  Scenario: Get data of starred board
    #POST a new star on the latest created board
    Given path 'members/' +  idUsername + '/boardStars'
    And form field idBoard = idCreatedBoard
    And form field pos = 'top'
    And form field key = java.lang.System.getenv('trl_key');
    And form field token = java.lang.System.getenv('trl_token');
    When method post
    Then status 200
    And print response

    * def body =
    """
   {
      "_id": '#string',
      "idBoard": '#string',
      "pos": '#number'
   }
    """
    #GET data of starred board action
    Given path 'boards/' + idCreatedBoard + '/boardStars'
    And form field key = java.lang.System.getenv('trl_key');
    And form field token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200
    And match $[0] contains body
    And print response

  Scenario: Fetch open cards on a board
    * def body =
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

    Given path 'boards/' + idCreatedBoard + '/cards'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200
    And match $[0] contains body
    And print response

  Scenario: Fetch card data by id
    Given path 'boards/' + idCreatedBoard + '/cards/' + idCreatedCard
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200
    And match $.id == idCreatedCard
    And print response

  Scenario: Fetch checklists data

      #POST checklist on card
    Given path 'checklists'
    And form field idCard = idCreatedCard
    And form field name = 'new checklist name'
    And form field key = java.lang.System.getenv('trl_key');
    And form field token = java.lang.System.getenv('trl_token');
    When method post
    Then status 200
    And print response

    * def resBody =
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

    Given path 'boards/' + idCreatedBoard + '/checklists'
    And form field key = java.lang.System.getenv('trl_key');
    And form field token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200
    And match $[0] contains resBody
    And print response

  Scenario: Get the Custom Field Definitions that exist on a board.

      #'#(idCreatedBoard)'- id of created board pass as param to json
    * def jsonBodyData =
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
    #Enable board plugins custom fields on newly created board
    Given path 'boards/' + idCreatedBoard + '/boardPlugins'
    And form field idPlugin = idCustomFieldsPlugin
    And form field key = java.lang.System.getenv('trl_key');
    And form field token = java.lang.System.getenv('trl_token');
    When method post
    Then status 200
    And print response

    #Create custom field list with two options on the board
    Given path 'customFields'
    And header Content-Type = 'application/json'
    And request jsonBodyData
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    When method post
    And print jsonPost
    Then status 200
    And print response

    #Get data for created custom field
    Given path 'boards/' + idCreatedBoard + '/customFields'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200
    And match $[0].id == '#string'
    And match $[0].idModel == idCreatedBoard
    And print response

  Scenario: Get labels data from a board

    * def jsonMatch =
      """
  {
    "id": '#string',
    "name": '#string',
    "color": '#string'
  }
      """
    Given path 'boards/' + idCreatedBoard + '/labels'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200
    And match $[0] contains jsonMatch
    And print response

  Scenario: Get list date from a board
    * def jsonMatch =
        """
  {
    "id": '#string',
    "name": '#string',
    "cards": '#array'
  }
        """
    Given path 'boards/' + idCreatedBoard + '/lists'
    And param cards = 'all'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200
    And match $[0] contains jsonMatch
    And print response

  Scenario: Get list date from a board with filter option

    Given path '/lists/' + idFirstList + '/closed'
    And param value = true
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    And request '/lists/' + idFirstList + '/closed'
    When method put
    Then status 200

    * def jsonMatch =
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
    Given path '/boards/' + idCreatedBoard + '/lists/closed'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200
    And match response[0] contains jsonMatch
    And print response

  Scenario: Get the members for a board

    * def jsonMatch =
    """
  {
    "id": '#(idUsername)',
    "fullName": "trelloautoapitest",
    "username": "userautoapitest"
  }
    """
    Given path '/boards/' + idCreatedBoard + '/members'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200
    And match response[0] == jsonMatch
    And print response

  Scenario: Get information about the memberships users have to the board.

    * def jsonMatch =
    """
  {
    "id": '#string',
    "idMember": '#(idUsername)',
    "memberType": "admin",
    "unconfirmed": false,
    "deactivated": false
  }
    """
    Given path '/boards/' + idCreatedBoard + '/memberships'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200
    And match response[0] == jsonMatch
    And print response
    And print jsonMatch

  Scenario: List the Power-Ups for a board

    * def jsonMatch =
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
    Given path '/boards/' + idCreatedBoard + '/plugins'
    And param key = java.lang.System.getenv('trl_key');
    And param token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200
    And match response[0] contains jsonMatch
    And print response
    And print jsonMatch