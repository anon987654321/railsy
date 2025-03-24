# frozen_string_literal: true

class SearchReflex < ApplicationReflex
  def search(query = nil)
    if query.blank?
      @ports = Port.all
    else
      @ports = Port.where("name LIKE ?", "%#{ query }%")
    end

    morph "#live_results", render(partial: "ports/list", locals: { ports: @ports })
    morph "#reset_link", render(partial: "shared/reset_link", locals: { query: query })
  end
end

