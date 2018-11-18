# frozen_string_literal: true

module Unwrappr
  RSpec.describe Environment do
    describe 'temporary_environment' do
      subject(:environment) { Environment.with_environment_variable(name, value, &block) }

      let(:name) { 'MY_ENVIRONMENT_VARIABLE' }
      let(:value) { 'my-environment-value' }
      let(:block) { -> { block_return_value } }
      let(:block_return_value) { 42 }

      context 'given no prior environment variable set' do
        it 'changes the environment to the new value (during the yield)' do
          Environment.with_environment_variable(name, value) do
            expect(ENV[name]).to eq(value)
          end
        end

        it 'removes the environment variable' do
          environment
          expect(ENV[name]).to eq(nil)
        end

        it 'returns the value returned from the yield' do
          expect(environment).to eq(block_return_value)
        end
      end

      context 'given a prior environment variable set' do
        let(:original_value) { 'an-existing-environment-value' }
        before { ENV[name] = original_value }
        after { ENV[name] = nil }

        it 'changes the environment to the new value (during the yield)' do
          Environment.with_environment_variable(name, value) do
            expect(ENV[name]).to eq(value)
          end
        end

        it 'restores the original value' do
          environment
          expect(ENV[name]).to eq(original_value)
        end

        it 'returns the value returned from the yield' do
          expect(environment).to eq(block_return_value)
        end

        context 'and given the block raises an error' do
          let(:block) { -> { raise 'an-example-error' } }

          it 'raises the error' do
            expect { environment }.to raise_error('an-example-error')
          end

          it 'restores the original value' do
            expect { environment }.to raise_error('an-example-error')
            expect(ENV[name]).to eq(original_value)
          end
        end
      end
    end
  end
end
