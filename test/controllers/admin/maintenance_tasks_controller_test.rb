# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
require 'test/unit'

class Admin::MaintenanceTasksControllerTest < ActionController::TestCase
  include ControllerTest::DefaultHelper

  setup do
    GeoIp.stubs(:activated?)
  end

  context '#index' do

    test 'index cannot be accessed by non-root' do
      login_as(:bob)

      get :index

      assert_redirected_to teams_path
    end

    test 'get all maintenance tasks without ldap' do
      login_as(:admin)

      get :index

      maintenance_tasks = assigns(:maintenance_tasks)

      assert_equal 0, maintenance_tasks.size
    end

    test 'get all maintenance tasks with ldap enabled' do
      enable_ldap
      login_as(:admin)

      get :index
      maintenance_tasks = assigns(:maintenance_tasks)

      assert_equal 1, maintenance_tasks.size
    end

    context '#execute' do

      test 'execute cannot be accessed by non-root' do
        enable_ldap
        login_as(:bob)

        post :execute, params: { id: 3 }

        assert_redirected_to teams_path
      end

      test 'execute task' do
        enable_ldap
        mock_ldap_settings
        LdapConnection.any_instance.expects(:test_connection).returns(true)

        login_as(:admin)
        assert_difference('Log.count', 1) do
          post :execute, params: { id: 3 }
        end

        assert_template 'admin/maintenance_tasks/removed_ldap_users/result.html.haml'
        assert_match(/successfully/, flash[:notice])
      end

      test 'displays error if task execution fails' do
        enable_ldap

        login_as(:admin)
        assert_difference('Log.count', 1) do
          post :execute, params: { id: 3 }
        end

        assert_redirected_to admin_maintenance_tasks_path
        assert_match(/Task failed/, flash[:error])
      end

      test 'returns 404 if invalid maintenance task id' do
        login_as(:admin)

        assert_raise ActionController::RoutingError do
          post :execute, params: { id: 42, task_params: {} }
        end
      end

      test 'executes task and renders result page' do
        enable_ldap
        mock_ldap_settings
        login_as(:admin)

        LdapConnection.any_instance.expects(:test_connection)
          .returns(true)

        assert_difference('Log.count', 1) do
          post :execute, params: { id: 3 }
        end

        assert_template 'admin/maintenance_tasks/removed_ldap_users/result.html.haml'
        assert_match(/successfully/, flash[:notice])
      end

    end

  end

end
