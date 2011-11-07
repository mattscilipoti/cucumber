Feature: Rerun profile

  Background:
    Given a file named "cucumber.yml" with:
      """
      <%
      rerun = File.file?('rerun.txt') ? IO.read('rerun.txt') : ""
      rerun_opts = rerun.to_s.strip.empty? ? "--format progress features" : "--format pretty #{rerun}"
      %>
      rerun: <%= rerun_opts %> --format rerun --out rerun.txt --strict --tags ~@wip
      """

    And a file named "features/one_passing_one_failing.feature" with:
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

        Scenario: Always passes
          Given a passing step

      """

    And a file named "features/always_failing.feature" with:
      """
      Feature: One failing example

        Scenario: Always fails
          Given a failing step

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

  Scenario: One scenario, always passes
    When I run cucumber "features/always_passing.feature -p rerun"
    Then it should pass with:
      """
      Using the rerun profile...
      .

      1 scenario (1 passed)
      1 step (1 passed)
      """
    Then the file "rerun.txt" should contain exactly:
      """
      """

    When I run cucumber "features/always_passing.feature -p rerun"
    Then it should pass with:
      """
      1 scenario (1 passed)
      """
    Then the file "rerun.txt" should contain exactly:
      """
      """


  Scenario: One scenario, always fails
    When I run cucumber "features/always_failing.feature -p rerun"
    Then it should fail with:
      """
      Using the rerun profile...
      F

      (::) failed steps (::)

       (RuntimeError)
      ./features/step_definitions/steps.rb:6:in `/a failing step/'
      features/always_failing.feature:4:in `Given a failing step'

      Failing Scenarios:
      cucumber -p rerun features/always_failing.feature:3 # Scenario: Always fails

      1 scenario (1 failed)
      1 step (1 failed)
      """
    Then the file "rerun.txt" should contain exactly:
      """
      features/always_failing.feature:3
      """

    When I run cucumber "features/always_failing.feature -p rerun"
    Then it should fail with:
      """
      1 scenario (1 failed)
      """
    Then the file "rerun.txt" should contain exactly:
      """
      features/always_failing.feature:3
      """

    
  Scenario: Multiple scenarios, with one failing, which subsequently passes
    When I run cucumber "-p rerun"
    Then it should fail with:
      """
      Using the rerun profile...
      F.-.F

      (::) failed steps (::)

       (RuntimeError)
      ./features/step_definitions/steps.rb:6:in `/a failing step/'
      features/always_failing.feature:4:in `Given a failing step'

       (RuntimeError)
      ./features/step_definitions/steps.rb:6:in `/a failing step/'
      features/one_passing_one_failing.feature:4:in `Given a <certain> step'

      Failing Scenarios:
      cucumber -p rerun features/always_failing.feature:3 # Scenario: Always fails
      cucumber -p rerun features/one_passing_one_failing.feature:3 # Scenario: 

      4 scenarios (2 failed, 2 passed)
      4 steps (2 failed, 2 passed)
      """

    And the file "rerun.txt" should contain exactly:
      """
      features/always_failing.feature:3 features/one_passing_one_failing.feature:9
      """

    # overwrite step to make it pass
    # TODO: anyone have a better suggestion for "which subsequently passes"?
    Given a file named "features/step_definitions/steps.rb" with:
      """
      Given /a passing step/ do
        #does nothing
      end

      Given /a failing step/ do
        step "a passing step"
      end
      """

    # First run after passing, runs only failing features
    When I run cucumber "-p rerun"
    Then it should pass with:
      """
      2 scenarios (2 passed)
      """
    And the file "rerun.txt" should be empty


    # Second run after passing, runs all (with -f progress)
    When I run cucumber "-p rerun"
    Then it should pass with:
      """
      Using the rerun profile...
      ..-..

      4 scenarios (4 passed)
      4 steps (4 passed)
      """
    And the file "rerun.txt" should be empty
