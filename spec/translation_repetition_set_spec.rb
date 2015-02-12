require 'spec_helper'
require 'cofgratx/cfg/translation_repetition_set_error'
require 'cofgratx/cfg/translation_repetition_set'

describe TranslationRepetitionSet do

  context '.set_offset' do
    before do
      @set = described_class.new
    end

    it { expect{ @set.set_offset(1) }.to_not raise_error }
    it { expect{ @set.set_offset(13) }.to_not raise_error }

    [ "gibberish", nil, "", 1.234, "2", "three" ].each do |bad_input|
      it { expect{ @set.set_offset(bad_input) }.to raise_error(ArgumentError, "expected Fixnum; got '#{bad_input.class.name}'") }
    end

    [ 0, -3, -1 ].each do |bad_input|
      it { expect{ @set.set_offset(bad_input) }.to raise_error(ArgumentError, "expected positive Fixnum; got '#{bad_input}'") }
    end
  end

  context '.set_translation' do
    before do
      @set = described_class.new
    end

    it { expect{ @set.set_translations(1) }.to_not raise_error }
    it { expect{ @set.set_translations([1]) }.to_not raise_error }
    it { expect{ @set.set_translations(13, "one", 5) }.to_not raise_error }
    it { expect{ @set.set_translations(["one", "two", 3, 4, 5]) }.to_not raise_error }

    [ [0], [1, 0, -3, 2], -44 ].each do |bad_input|
      it { expect{ @set.set_translations(bad_input) }.to raise_error(TranslationRepetitionSetError, "subrule number cannot be less than 1") }
    end

    [ [/bad/], [1.231], [nil] ].each do |bad_input|
      it { expect{ @set.set_translations(bad_input) }.to raise_error(ArgumentError, "expected Fixnum or String; got #{bad_input.first.class.name}") }
    end
  end

  context ".initialize" do
    it { expect{ described_class.new }.to_not raise_error }
    it { expect{ described_class.new(1) }.to_not raise_error }
    it { expect{ described_class.new(1, "foo", "bar", 6) }.to_not raise_error }
    it { expect{ described_class.new(1, ["foo", "bar", 6]) }.to_not raise_error }

    it "sets the offset and translations by calling the appropriate methods" do
      expect_any_instance_of(described_class).to receive(:set_offset).and_call_original
      expect_any_instance_of(described_class).to receive(:set_translations).and_call_original

      set = described_class.new(1, "foo", 3)
    end

    it "sets the offset and translations by calling the appropriate methods with the corresponding input" do
      expect_any_instance_of(described_class).to receive(:set_offset).with(1)
      expect_any_instance_of(described_class).to receive(:set_translations).with(["foo",3])

      set = described_class.new(1, "foo", 3)
    end
  end
end
