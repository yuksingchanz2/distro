(function($) {
  $(function() {
    $("input.jqTextboxList").each(function() {
      var $this = $(this);
      var opts = $.extend({}, $this.metadata());
      $this.textboxlist(opts);
    });
  });
})(jQuery);
