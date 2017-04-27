RSpec.shared_examples "a TSV" do

  describe "#load_tsv" do
    it "loads a string" do
      tsv = File.read(path)
      subject.load_tsv(tsv)
      expect(subject.tsv).to eq(tsv)
    end
    it "loads an IO" do
      tsv = File.read(path)
      subject.load_tsv(tsv)
      expect(subject.tsv).to eq(tsv)
    end
  end

  describe "#load_tsv_file" do
    specify {
      subject.load_tsv_file(path)
      expect(subject.tsv).to eq(File.read(path))
    }
  end

end
