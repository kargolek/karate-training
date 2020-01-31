Feature: Trello boards api tests

  Background:
    * url 'https://api.trello.com/1/'
    Given path 'boards'
    And form field name = 'NewName'
    And form field key = java.lang.System.getenv('trl_key');
    And form field token = java.lang.System.getenv('trl_token');
    When method post
    * def json = response
    * def id = get json.id

  Scenario: Request all boards data
    Given path 'members/me/boards'
    And form field key = java.lang.System.getenv('trl_key');
    And form field token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200
    And match $[0].name contains '#string'

  Scenario: Request single board data
    Given path 'boards'
    Given path id
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
      "data":{
         "creationMethod":"automatic",
         "board":{
            "id":'#string',
            "name": "NewName",
            "shortLink":'#string'
         }
      },
      "type":"createBoard",
      "date":'#string',
      "limits": '#notnull',
      "memberCreator":{
         "id":'#string',
         "activityBlocked":'#boolean',
         "avatarHash":'#null',
         "avatarUrl":'#null',
         "fullName":"trelloautoapitest",
         "idMemberReferrer":'#null',
         "initials":"T",
         "nonPublic":{

         },,
         "nonPublicAvailable":true,
         "username":"userautoapitest"
      }
   }
    """
    Given path 'boards'
    And path id
    And path 'actions'
    And form field limit = 1
    And form field key = java.lang.System.getenv('trl_key');
    And form field token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200
    And match $[0] contains responseBody