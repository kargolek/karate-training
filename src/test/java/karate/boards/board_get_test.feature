Feature: Trello boards api tests

  Background:
    * url 'https://api.trello.com/1/'
    Given path 'boards'
    And form field name = 'NewName'
    And form field defaultLists = 'true'
    And form field key = java.lang.System.getenv('trl_key');
    And form field token = java.lang.System.getenv('trl_token');
    When method post
    Then status 200
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

    Given path 'cards/'
    And form field name = 'test_card_' + java.util.UUID.randomUUID();
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

  Scenario: Request single board data
    Given path 'boards'
    Given path idCreatedBoard
    Given path 'name'
    And form field key = java.lang.System.getenv('trl_key');
    And form field token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200
    And match $._value contains 'NewName'

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

  Scenario: Get data of starred board
    #POST a new star on the latest created board
    Given path 'members/' +  idUsername + '/boardStars'
    And form field idBoard = idCreatedBoard
    And form field pos = 'top'
    And form field key = java.lang.System.getenv('trl_key');
    And form field token = java.lang.System.getenv('trl_token');
    When method post
    Then status 200

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
    And form field key = java.lang.System.getenv('trl_key');
    And form field token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200
    And match $[0] contains body

  Scenario: Fetch card data by id
    Given path 'boards/' + idCreatedBoard + '/cards/' + idCreatedCard
    And form field key = java.lang.System.getenv('trl_key');
    And form field token = java.lang.System.getenv('trl_token');
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


    #TODO Need to fix that scenario
  Scenario: Get the Custom Field Definitions that exist on a board.

    * def aaa =
    """
{
    "idModel": "5e39afbdbb87f55875349796",
    "modelType": "board",
    "name": "My dropdown list",
    "options": [
        {
            "color": "none",
            "value": {
                "text": "First"
            },
            "pos": 1024
        },
        {
            "color": "none",
            "value": {
                "text": "Second"
            },
            "pos": 2048
        }
    ],
    "pos": "bottom",
    "type": "list",
    "display_cardFront": true
}
    """
    #Enable custom fields plugin on board
    Given path 'boards/' + idCreatedBoard + '/boardPlugins'
    And form field idPlugin = idCustomFieldsPlugin
    And form field key = java.lang.System.getenv('trl_key');
    And form field token = java.lang.System.getenv('trl_token');
    When method post
    Then status 200

    Given path '/customFields/'
    And form field key = java.lang.System.getenv('trl_key');
    And form field token = java.lang.System.getenv('trl_token');
    When request aaa
    And header Content-Type = 'application/json'
    And method post

    Then status 200