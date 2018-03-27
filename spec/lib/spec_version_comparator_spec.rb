require 'spec_helper'

RSpec.describe Unwrappr::SpecVersionComparator do
  subject(:perform) { described_class.perform(specs_before, specs_after) }
  let(:specs_before) { [] }
  let(:specs_after) { [] }

  context 'empty specs lists' do
    it 'returns empty change set' do
      expect(subject).to be_empty
    end
  end

  context 'version upgrade' do
    let(:specs_before) { ['cloudinary (1.9.1)'] }
    let(:specs_after) { ['cloudinary (1.10.0)'] }
    it 'returns versions' do
      expect(subject).to eq([{ dependency: 'cloudinary', before: '1.9.1', after: '1.10.0' }])
    end
  end

  context 'added dependency' do
    let(:specs_before) { [] }
    let(:specs_after) { ['cloudinary (1.10.0)'] }
    it 'returns versions' do
      expect(subject).to eq([{ dependency: 'cloudinary', before: nil, after: '1.10.0' }])
    end
  end

  context 'removed dependency' do
    let(:specs_before) { ['cloudinary (1.9.1)'] }
    let(:specs_after) { [] }
    it 'returns versions' do
      expect(subject).to eq([{ dependency: 'cloudinary', before: '1.9.1', after: nil }])
    end
  end

  context 'multiple dependencies' do
    let(:specs_before) { ['cloudinary (1.9.1)', 'apiary (2.3.1)'] }
    let(:specs_after) { ['cloudinary (1.9.1)', 'apiary (3.1.1)'] }

    it 'returns all dependencies' do
      expect(subject.size).to eq 2
    end
  end
end
