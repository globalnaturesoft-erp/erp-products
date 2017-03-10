module Erp::Products
  class Category < ApplicationRecord
		mount_uploader :image_url, Erp::Products::CategoryImageUploader
		
		validates :name, :presence => true
		
		has_many :products
    belongs_to :creator, class_name: "Erp::User"
    belongs_to :parent, class_name: "Erp::Products::Category", optional: true
    has_many :children, class_name: "Erp::Products::Category", foreign_key: "parent_id"
    
    has_many :related_categories, foreign_key: "parent_id", inverse_of: :parent, dependent: :destroy
    accepts_nested_attributes_for :related_categories, :reject_if => lambda { |a| a[:category_id].blank? }
    
    # Filters
    def self.filter(query, params)
      params = params.to_unsafe_hash
      and_conds = []
      
      # show archived items condition - default: false
			show_archived = false
			
			#filters
			if params["filters"].present?
				params["filters"].each do |ft|
					or_conds = []
					ft[1].each do |cond|
						# in case filter is show archived
						if cond[1]["name"] == 'show_archived'
							# show archived items
							show_archived = true
						else
							or_conds << "#{cond[1]["name"]} = '#{cond[1]["value"]}'"
						end
					end
					and_conds << '('+or_conds.join(' OR ')+')' if !or_conds.empty?
				end
			end
      
      #keywords
      if params["keywords"].present?
        params["keywords"].each do |kw|
          or_conds = []
          kw[1].each do |cond|
            or_conds << "LOWER(#{cond[1]["name"]}) LIKE '%#{cond[1]["value"].downcase.strip}%'"
          end
          and_conds << '('+or_conds.join(' OR ')+')'
        end
      end
      
      # join with users table for search creator
      query = query.joins("LEFT JOIN erp_products_categories parents_erp_products_categories ON parents_erp_products_categories.id = erp_products_categories.parent_id")
      
      # showing archived items if show_archived is not true
			query = query.where(archived: false) if show_archived == false

      query = query.where(and_conds.join(' AND ')) if !and_conds.empty?
      
      return query
    end
    
    def self.search(params)
      query = self.all
      query = self.filter(query, params)
      
      # order
      if params[:sort_by].present?
        order = params[:sort_by]
        order += " #{params[:sort_direction]}" if params[:sort_direction].present?
        
        query = query.order(order)
      end
      
      return query
    end
    
    # data for dataselect ajax
    def self.dataselect(keyword='')
      query = self.all
      
      if keyword.present?
        keyword = keyword.strip.downcase
        query = query.where('LOWER(name) LIKE ?', "%#{keyword}%")
      end
      
      query = query.limit(8).map{|category| {value: category.id, text: category.name} }
    end
    
    # product count
    def product_count
			products.count
		end
    
    def archive
			update_columns(archived: true)
		end
		
		def unarchive
			update_columns(archived: false)
		end
    
    def self.archive_all
			update_all(archived: true)
		end
    
    def self.unarchive_all
			update_all(archived: false)
		end
    
    # display name
    def parent_name
			parent.present? ? parent.name : ''
		end
		
		# display name with parent
    def full_name
			names = [self.name]
			p = self.parent
			while !p.nil? do
				names << p.name
				p = p.parent
			end
			names.reverse.join(" >> ")
		end
    
  end
end
