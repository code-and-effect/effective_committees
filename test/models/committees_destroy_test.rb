require 'test_helper'

# Deleting a committee must delete all of its associated files, including purging the
# underlying Active Storage blobs. Previously the committee_folders/committee_files
# associations used `dependent: :delete_all`, which deletes rows via raw SQL without
# running callbacks — orphaning the uploaded files in storage (and leaving them
# downloadable via their old URLs). They now use `dependent: :destroy`.
#
# Active Storage purges blobs in an `after_destroy_commit` callback, which only fires
# on a real COMMIT, so these tests run without the wrapping test transaction.
class CommitteesDestroyTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  teardown do
    Effective::Committee.where(id: @committee_ids).destroy_all if @committee_ids.present?
  end

  def create_committee_with_unique_title
    committee = Effective::Committee.create!(title: "Destroy Test #{SecureRandom.hex(6)}")
    (@committee_ids ||= []) << committee.id
    committee
  end

  def attach_file_to(folder, filename: 'document.txt')
    committee_file = folder.committee_files.build
    committee_file.file.attach(
      io: StringIO.new('committee file contents'),
      filename: filename,
      content_type: 'text/plain'
    )
    committee_file.save!
    committee_file
  end

  test 'destroying a committee destroys its folders and files and purges the attached blobs' do
    committee = create_committee_with_unique_title
    folder = committee.committee_folders.create!(title: 'Documents')
    committee_file = attach_file_to(folder)

    blob = committee_file.file.blob
    key = blob.key

    assert blob.service.exist?(key), 'precondition: file should be present in storage'
    assert_equal 1, committee.reload.committee_files_count

    committee.destroy!

    refute Effective::Committee.exists?(committee.id), 'committee should be destroyed'
    refute Effective::CommitteeFolder.exists?(folder.id), 'folder should be destroyed'
    refute Effective::CommitteeFile.exists?(committee_file.id), 'committee file should be destroyed'
    refute ActiveStorage::Blob.exists?(blob.id), 'blob record should be purged'
    refute blob.service.exist?(key), 'file should be removed from storage'
  end

  test 'destroying a committee purges files nested in sub-folders' do
    committee = create_committee_with_unique_title
    parent = committee.committee_folders.create!(title: 'Parent')
    child = committee.committee_folders.create!(title: 'Child', committee_folder: parent)
    nested_file = attach_file_to(child, filename: 'nested.txt')

    blob = nested_file.file.blob
    key = blob.key
    assert blob.service.exist?(key), 'precondition: nested file should be present in storage'

    committee.destroy!

    refute Effective::CommitteeFolder.exists?(parent.id), 'parent folder should be destroyed'
    refute Effective::CommitteeFolder.exists?(child.id), 'child folder should be destroyed'
    refute Effective::CommitteeFile.exists?(nested_file.id), 'nested file should be destroyed'
    refute ActiveStorage::Blob.exists?(blob.id), 'nested blob record should be purged'
    refute blob.service.exist?(key), 'nested file should be removed from storage'
  end
end
