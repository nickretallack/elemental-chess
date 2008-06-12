#!/usr/bin/env ruby

module Geometry
  class DimensionError < ArgumentError; end

  # WARNING: Geometry::Vector is not the same as ::Vector, if you require matrix or mathn
  # and include or included Geometry, Vector of matrix.rb will have precedence.
  # FIXME: add Numeric * Vector
  # FIXME: add TC for #to_point to GeometryTest
  class Vector
    class <<self
      alias [] new
    end

    # A new Vector
    # Example:
    #	Vector.new(1,2,3) # => #<Vector 1, 2, 3>
    def initialize(*components)
      @components = components
      @components.freeze
    end

    X = Vector[1]
    Y = Vector[0,1]
    Z = Vector[0,0,1]

    # Value-equality of this vector with another
    # Tests if all components of the same dimension are == to the other
    def ==(other)
      other.to_a == @components
    end
    alias eql? ==

      # Read components like an array.
      def [](*index)
        @components[*index]
      end

    # Returns the magnitude of the vector (also known as length, size, norm or modulus)
    def magnitude
      @magnitude ||= Math.sqrt(@components.inject(0) { |s,c| s+(c**2) })
    end

    # The dimensions of this vector, e.g. Vector.new(1,2,3).dimensions # => 3
    def dimensions
      @components.length
    end

    # Returns whether all elements of the Vector are zero?
    def zero?
      @components.all? { |c| c.zero? }
    end

    # Returns a vector of given dimension. If new vector has more
    # dimensions than the old one the additional dimensions are filled
    # with zeros. If it has less, they are truncated.
    def redim(d, fill=0)
      #Vector[Array.new(d, 0).fill(0, [dimensions, d].min) { |i| @components[i] }]
      Vector[*(@components[0,d]+Array.new([d-dimensions,0].max, fill))]
    end


    # Returns a vector with same orientation and direction but with unit norm (1)
    def normalize
      raise ArgumentError, "Can't normalize zero-vector" if zero?
      Vector[*@components.map { |c| c/magnitude }]
    end

    # Returns the vector that represents sum of the two vectors
    def +(vector)
      vectors = coerce(vector)
      Vector[*vectors.last.to_a.zip(vectors.first.to_a).map { |(a,b)| a+b }]
    end

    # Returns the vector that represents difference of the two vectors
    def -(vector)
      vectors = coerce(vector)
      Vector[*vectors.last.to_a.zip(vectors.first.to_a).map { |(a,b)| a-b }]
    end

    # With a scalar factor, it will return a vector with all
    # components multiplied by that factor, with another vector
    # it will return the inner product
    def *(scalar)
      return dot_product(scalar) if Vector === scalar
      Vector[*@components.map{ |a| a*scalar }]
    end

    # Returns a vector with all components divided by that factor
    def /(scalar)
      Vector[*@components.map{ |a| a/scalar }]
    end

    # Returns a vector with inverted direction
    def -@
      Vector[*@components.map{ |a| -a }]
    end

    # Just for completness
    def +@
      dup
    end

    # The cross product of this vector with another
    # Returns a vector which is orthagonal to the two factors
    def cross_product(other) # FIXME add n dimensional vector cross product
      raise DimensionError, "cross product is only defined for 2 and 3 dimensions" if (2 > dimensions || dimensions > 3)
      raise DimensionError, "cross product is only defined for 2 and 3 dimensions" if (2 > other.dimensions || other.dimensions > 3)
      a = dimensions == 2 ? to_a+[0] : to_a
      b = other.dimensions == 2 ? other.to_a+[0] : other.to_a
      Vector[
        (a[1]*b[2] - a[2]*b[1]),
        (a[2]*b[0] - a[0]*b[2]),
        (a[0]*b[1] - a[1]*b[0])
      ]
    end
    alias outer_product cross_product

    # The dot product of this vector with another
    # Returns a scalar
    def dot_product(vector)
      vectors = coerce(vector)
      vectors.last.to_a.zip(vectors.first.to_a).inject(0) { |s,(a,b)| s+a*b }
    end

    # Coerce vectors (redims them to the same dimensions)
    def coerce(*others)
      objs = others+[self]
      dims = objs.map{ |obj| obj.dimensions }.max
      objs.map { |obj| obj.redim(dims) }
    end

    # Point for this vector as position vector, also see Point#+, Point#-
    def to_point
      Point.new(*@components)
    end

    # A vector can always become converted to a vector :)
    def to_vector
      dup
    end

    # The components of the vector as array
    def to_a
      @components.dup
    end

    # String representation of vector
    def to_s
                        "<#{@components.join(', ')}>"
    end

    def inspect # :nodoc:
                        "#<Vector #{@components.join(", ")}>"
    end

    def dup # :nodoc:
      Vector[*@components]
    end

    # Enable use of Vector as hash-key
    def hash # :nodoc:
      @components.hash
    end
  end
end

