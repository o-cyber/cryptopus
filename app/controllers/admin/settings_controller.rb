# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.
require 'countries/global'

class Admin::SettingsController < ApplicationController

  helper_method :general_settings

  def index
    authorize Setting
    Setting.all
  end

  def update_all
    authorize Setting
    update_settings
    flash[:notice] = t('flashes.admin.settings.successfully_updated')
    respond_to do |format|
      format.html { redirect_to admin_settings_path }
    end
  end

  private

  def update_settings
    params[:setting].each do |key, value|
      setting = Setting.find_by(key: key)
      setting.update(value: value)
      collect_errors(setting) if setting.errors.any?
    end
  end

  def collect_errors(setting)
    flash[:error] = setting.errors[:value].join(', ')
  end

  def general_settings
    all_settings.select do |s|
      s.key =~ /^general_*/
    end
  end

  def all_settings
    @all_settings ||= Setting.all
  end

end
