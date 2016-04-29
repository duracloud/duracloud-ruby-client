module Duracloud
  RSpec.describe Manifest do

    let(:body) { <<-EOS
space-id	content-id	MD5
auditlogs	localhost/51/auditlogs/localhost_51_auditlogs-2014-09-10-15-56-07.tsv	6992f8e57dafb17335f766aa2acf5942
auditlogs	localhost/51/photos/localhost_51_photos-2014-09-10-15-55-01.tsv		820e786633fb495db447dc5d5cf0b2bd
EOS
    }

  end
end
