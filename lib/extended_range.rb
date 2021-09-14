# frozen_string_literal: true

require_relative "extended_range/version"
require_relative "core_extensions/range/operations"
require_relative "core_extensions/range/checks"

Range.include CoreExtensions::Range::Operations
Range.include CoreExtensions::Range::Checks
