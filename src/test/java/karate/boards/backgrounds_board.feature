Feature: Preconditions for boards api tests

  Scenario: Create board, get list and create one card.
    * url baseUrl
    * def boardNameRandom = org.apache.commons.lang.RandomStringUtils.randomAlphabetic(10);
    * def cardNameRandom = org.apache.commons.lang.RandomStringUtils.randomAlphabetic(10);
    * def idUsername = '5e23b17009db88314e564927'
    * def idCustomFieldsPlugin = '56d5e249a98895a9797bebb9'
    * def idMember = '5e31b359cd8dfc1384b2e515'
    * def idCalendarPlugin = '55a5d917446f517774210011'

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

    Given path 'boards/' + idCreatedBoard + '/lists'
    And form field key = java.lang.System.getenv('trl_key');
    And form field token = java.lang.System.getenv('trl_token');
    When method get
    Then status 200
    * def jsonLists = response
    * def idFirstList = get jsonLists[0].id

    Given path 'cards/'
    And form field name = cardNameRandom
    And form field idList = idFirstList
    And form field key = java.lang.System.getenv('trl_key');
    And form field token = java.lang.System.getenv('trl_token');
    When method post
    Then status 200
    * def resBody = response
    * def idCreatedCard = get resBody.id