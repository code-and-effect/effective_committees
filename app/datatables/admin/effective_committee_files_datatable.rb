module Admin
  class EffectiveCommitteeFilesDatatable < Effective::Datatable
    datatable do
      reorder :position

      col :updated_at, visible: false
      col :created_at, visible: false

      col :id, visible: false

      col :committee

      col :committee_folder, label: "Folder" do |committee_file|
        admin_committees_parents(committee_file.committee_folder)
      end

      col(:to_s, label: 'Files') do |committee_file|
        link_to(committee_file.to_s, url_for(committee_file.file), title: committee_file.to_s, target: '_blank')
      end

      col :title, visible: false
      col :notes

      actions_col
    end

    collection do
      Effective::CommitteeFile.deep.all
    end

  end
end
