Feature: Rerun formatter
  In order to provide a workflow in which failing Scenarios are easily processed until they pass
  Developers should be able to create a list of failing tests for each run.

  Background:
    Given a file named "features/one_passing_one_failing.feature" with:
      """
      Feature: One passing example, one failing example

        Scenario Outline:
          Given a <certain> step

        Examples:
          |certain|
          |passing|
          |failing|
     """

    And a file named "features/always_passing.feature" with:
      """
      Feature: One passing example

        Scenario Outline: Always passes
          Given a <certain> step

        Examples:
          |certain|
          |passing|
      """

    And a file named "features/step_definitions/steps.rb" with:
      """
      Given /a passing step/ do
        #does nothing
      end

      Given /a failing step/ do
        fail
      end
      """

  Scenario: One failing scenario
    When I run cucumber "features/one_passing_one_failing.feature -r features -f rerun"
    Then it should fail with:
    """
    features/one_passing_one_failing.feature:9
    """

  Scenario: All pass
    When I run cucumber "features/always_passing.feature -r features -f rerun"
    Then it should pass with exactly:
    """
    """
