(function() {
  // - General -

  function xdr(method, data, callback, errback) {
    var req;
    var url = buildUrl(data);
    if (XMLHttpRequest) {
      req = new XMLHttpRequest();
      if('withCredentials' in req) {
        req.open(method, url, true);
        req.onerror = errback;
        req.onreadystatechange = function() {
          if (req.readyState === 4) {
            if (req.status >= 200 && req.status < 400) {
              callback(req.responseText);
            } else {
              errback(new Error('Response returned with non-OK status'));
            }
          }
        };
        req.send(data);
      }
    } else if(XDomainRequest) {
      req = new XDomainRequest();
      req.open(method, url);
      req.onerror = errback;
      req.onload = function() {
        callback(req.responseText);
      };
      req.send(data);
    } else {
      errback(new Error('CORS not supported'));
    }
  }

  var buildUrl = function(data){
    if (data.pageName) {
      url = window.howitzer_stat_url + "/pages/" + data.pageName;
    } else {
      url = window.howitzer_stat_url + "/page_classes"
      if (data.url && data.title) { url += "?url=" + data.url + "&title=" + data.title; }
    }
    return url;
  };

  // - Tooltip -

  var addButton = function(text) {
    var pageNameElement = document.createElement('div');
    pageNameElement.setAttribute('class','hs-number');
    pageNameElement.innerHTML = text || 'Not Found';

    var statButton = document.createElement('li');
    if (text == null) {
      statButton.setAttribute('class', 'hs-button');
    } else {
      statButton.setAttribute('class', 'hs-button-active');
      statButton.setAttribute('style', 'display: block;');
      statButton.setAttribute('data-page-name', text);
      statButton.addEventListener('click', function () {
        if (isCurrentPageCached()) {
          hideToolTip();
          showPopup();
        } else {
          setStatusInfo('Loading');
          var currentPage = this.getAttribute('data-page-name');
          cacheCurrentPage(currentPage);
          var data = {pageName: currentPage};
          xdr('GET', data, featuresByClassNameHandler, errorHandler);
        }
      });
    }
    statButton.appendChild(pageNameElement);
    getToolTipEl().appendChild(statButton);
  };

  var clearToolTip = function() {
    getToolTipEl().innerHTML = '';
  };

  var setStatusInfo = function(text) {
    getToolTipEl().innerHTML = '<li class="hs-button"><div class="hs-number">' + text + '...</div></li>';
  };

  var setStatusError = function(text) {
    var errorMsg = text == null ? 'Error' : text;
    getToolTipEl().innerHTML = '<li class="hs-button"><div class="hs-number error">' + errorMsg + '</div></li>';
  };

  var cacheCurrentPage = function(text){
    getToolTipEl().setAttribute('data-active-page', text);
  };

  var isCurrentPageCached = function() {
    return !!getToolTipEl().getAttribute('data-active-page');
  };

  var getToolTipEl = function() {
    return document.getElementById('hs_tooltip')
  };

  var hideToolTip = function() {
    getToolTipEl().setAttribute("style", "display: none")
  };

  var showToolTip = function() {
    getToolTipEl().setAttribute("style", "display: block")
  };

  // - Popup -
  var popupEl = function() {
    return document.getElementById('hs_popup');
  };

  var templateEl = function() {
    return document.getElementById('cucumberStat');
  };

  var closeBtnEl = function() {
    return document.getElementById('hs_popup__close');
  };

  var collapseAllEl = function() {
    return document.getElementById('hs_collapse_all');
  };

  var expandAllEl = function() {
    return document.getElementById('hs_expand_all');
  };

  var collapsibleElList = function() {
    return document.getElementsByClassName('collapsible');
  };

  var featureContainerElList = function() {
    return document.getElementsByClassName('feature-container');
  };

  var scenarioElList = function() {
    return document.getElementsByClassName('scenario');
  };

  var fileLinkElList = function() {
    return document.getElementsByClassName('web_url');
  };

  var featureDescriptionEl = function(uid) {
    return document.getElementById('fd_' + uid);
  };

  var scenarioContainerEl = function(uid) {
    return document.getElementById('sce_items_' + uid);
  };

  var closePopup = function() {
    popupEl().setAttribute('style','display: none;');
  };

  var showPopup = function() {
    popupEl().setAttribute('style','display: block;');
  };

  var collapseOrExpand = function(el) {
    if (el) {
      if (el.getAttribute('style').lastIndexOf('none') == -1) {
        el.setAttribute('style', 'display: none;');
      } else {
        el.setAttribute('style', '');
      }
    }
  };

  var collapseOrExpandScenario = function(uid) {
    collapseOrExpand(scenarioContainerEl(uid));
  };

  var collapseOrExpandFeature = function(uid) {
    collapseOrExpand(featureDescriptionEl(uid));
  };

  var collapseAll = function() {
    _.each(collapsibleElList(), function (el){ el.setAttribute('style', 'display: none;')});
  };

  var expandAll = function() {
    _.each(collapsibleElList(), function (el){ el.setAttribute('style', '')});
  };

  // - Handlers

  var errorHandler = function(error){
    console.log(error);
    setStatusError(null)
  };

  var pageClassesByTitleAndUrlHandler = function(data) {
    clearToolTip();
    var page_list = JSON.parse(data).page;
    if (page_list.length == 0) { addButton(null);}
    _.each(page_list, function (pageName){ addButton(pageName)});
  };

  var featuresByClassNameHandler = function(data){
    var activePage = getToolTipEl().getAttribute('data-active-page');
    hideToolTip();
    clearToolTip();
    addButton(activePage);

    var pageData = JSON.parse(data);
    if (pageData.features == ''){
      popupEl().innerHTML = 'There is no tests that include this page.';
    } else {
      popupEl().innerHTML = _.template(templateEl().innerHTML, pageData);
    }
    closeBtnEl().addEventListener('click', function () {
      closePopup();
      showToolTip();
    });

    collapseAllEl().addEventListener('click', function(e){
      collapseAll();
      e.preventDefault();
    });

    expandAllEl().addEventListener('click', function(e){
      expandAll();
      e.preventDefault();
    });

    _.each(featureContainerElList(), function(el){
      var uid = el.id.replace('feature_container_', '');
      el.addEventListener('click', function(e){
        e.preventDefault();
        collapseOrExpandFeature(uid);
      })
    });

    _.each(fileLinkElList(), function(el){
      el.addEventListener('click', function(e){
        e.stopPropagation();
      })
    });

    _.each(scenarioElList(), function(el){
      var uid = el.id.replace('sce_', '');
      el.addEventListener('click', function(e){
        e.preventDefault();
        collapseOrExpandScenario(uid);
      })
    });

    collapseAll();
    showPopup();
  };

  window.onload = function () {
    var baseHtml = '<ol id="hs_tooltip"></ol>' + "\n" + '<div id="hs_popup" style="display: none;">';
    document.getElementById('hs_wrapper').innerHTML = baseHtml;
    setStatusInfo('Page identification');
    var data = {url: document.URL || window.location.href, title: document.title};
    xdr('GET', data, pageClassesByTitleAndUrlHandler, errorHandler);
  };
})();