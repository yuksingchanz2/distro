(function($) {

$(function() {
  $("[autocomplete][autocomplete!=off]").each(function() {
    var $this = $(this);
    var options = $.extend({
      selectFirst:false,
      autoFill:false,
      matchCase:true,
      matchSubset:false
    }, $this.metadata());
    var urlOrData = $this.attr('autocomplete') || '';
    if (!urlOrData.match("^https?://")) {
      urlOrData = urlOrData.split(/\s*,\s*/);
    }
    $this.autocomplete(urlOrData, options);
    $this.attr('autocomplete', 'off');
  });
});

})(jQuery);
