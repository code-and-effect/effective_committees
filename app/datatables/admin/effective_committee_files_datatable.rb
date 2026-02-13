module Admin
  class EffectiveCommitteeFilesDatatable < Effective::Datatable
    bulk_actions do
      committee_folder.parents.each do |committee_folder|
        bulk_action(
          "Move to #{committee_folder.title}",
          effective_committees.bulk_move_admin_committee_files_path(committee_folder_id: committee_folder.id),
          data: { confirm: "Move selected files to #{committee_folder.title}?" }
        )
      end

      if committee_folder.committee_folder.present? && committee_folder.committee_folders.present?
        bulk_action_divider
      end

      committee_folder.children.each do |committee_folder|
        bulk_action(
          "Move to #{committee_folder.title}",
          effective_committees.bulk_move_admin_committee_files_path(committee_folder_id: committee_folder.id),
          data: { confirm: "Move selected files to #{committee_folder.title}?" }
        )
      end
    end

    datatable do
      reorder :position

      if attributes[:committee_folder_id].present?
        bulk_actions_col
      end

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

    def committee_folder
      if attributes[:committee_folder_id].present?
        @committee_folder ||= Effective::CommitteeFolder.find_by_id(attributes[:committee_folder_id])
      else
        @committee_folder ||= Effective::CommitteeFolder.new
      end
    end

  end
end
