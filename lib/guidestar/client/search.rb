module Guidestar
  class Client
    module Search
      def search(options={})
        path = '/GuideStarBasic'
        get(path, options)
      end
      def detailed_search(options={})
        path = '/GuideStarDetail'
        get(path, options)
      end
      def charity_check(options={})
        path = '/GuideStarCharityCheck'
        get(path, options)
      end
      def npo_validation(options={})
        path = '/GuideStarNPOValidation'
        get(path, options)
      end
    end
  end
end
