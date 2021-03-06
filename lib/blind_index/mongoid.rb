module BlindIndex
  module Mongoid
    module Criteria
      private

      def expr_query(criterion)
        if criterion.is_a?(Hash) && klass.respond_to?(:blind_indexes)
          criterion.keys.each do |key|
            key_sym = (key.is_a?(::Mongoid::Criteria::Queryable::Key) ? key.name : key).to_sym

            if (bi = klass.blind_indexes[key_sym])
              value = criterion.delete(key)

              bidx_key =
                if key.is_a?(::Mongoid::Criteria::Queryable::Key)
                  ::Mongoid::Criteria::Queryable::Key.new(
                    bi[:bidx_attribute],
                    key.strategy,
                    key.operator,
                    key.expanded,
                    &key.block
                  )
                else
                  bi[:bidx_attribute]
                end

              criterion[bidx_key] =
                if value.is_a?(Array)
                  value.map { |v| BlindIndex.generate_bidx(v, bi) }
                else
                  BlindIndex.generate_bidx(value, bi)
                end
            end
          end
        end

        super(criterion)
      end
    end

    module UniquenessValidator
      def create_criteria(base, document, attribute, value)
        if base.respond_to?(:blind_indexes) && (bi = base.blind_indexes[attribute])
          value = BlindIndex.generate_bidx(value, bi)
          attribute = bi[:bidx_attribute]
        end
        super(base, document, attribute, value)
      end
    end
  end
end
