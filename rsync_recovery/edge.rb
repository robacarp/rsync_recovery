module RsyncRecovery
  class Edge < Sequel::Model
    many_to_one :parent, key: :parent_id, class: HashedFile
    many_to_one :child, key: :child_id, class: HashedFile

    def inspect
      "<Edge parent:#{parent_id} child:#{child_id}>"
    end
  end
end
