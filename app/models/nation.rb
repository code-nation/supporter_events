class Nation < ApplicationRecord

  # ==
  # Associations
  # ==
  belongs_to :user
  has_many :sites

  # ==
  # Validations
  # ==
  validates_presence_of :slug
  validates_uniqueness_of :slug

  # ==
  # Methods
  # ==
  def nation_belongs_to_user?(user)
    user.id == self.user_id
  end

  def get_site(site_id)
    self.sites.each do |site|
      if site.nb_site_id.eql?(site_id)
        return site
      end
    end

    nil
  end

  def is_connected_to_nb?
    !self.token.blank?
  end

  def delete_non_existing_sites(existing_site_ids)
    self.sites.each do |site|
      unless existing_site_ids.include?(site.nb_site_id)
        site.destroy
      end
    end
  end

end
