class AddSummaryAndRiskScoreToArticles < ActiveRecord::Migration[7.0]
  def change
    add_column :articles, :summary, :text
    add_column :articles, :risk_score, :integer
  end
end
