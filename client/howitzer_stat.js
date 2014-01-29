(function() {
    // method to make AJAX request to web-service
    function xdr(method, data, callback, errback) {
        var req, url;
        var serviceDomain = "http://localhost:7000"; // add here domain of web-service where howitzer_stat is working

        if (data.pageName) {
            url = serviceDomain + "/pages/" + data.pageName;
        } else {
            url = serviceDomain + "/page_classes"
            if (data.url && data.title) { url += "?url=" + data.url + "&title=" + data.title; }
        }

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

    var errorHandler = function(error){
        alert(error);
    };

    var pageClassesByTitleAndUrlHandler = function(data) {

        var statButtonsContainer = document.getElementById('how_stat_result');

        _.each(JSON.parse(data).page, function (pageName){
            //        var pageName = JSON.parse(data).page[0];

//        var statButton = document.getElementById('howitzer_stat_btn');
            var statButton = document.createElement('div');
            statButton.setAttribute('class', 'how-stat-button non-active');
            statButton.setAttribute('style', 'display: none;');

//        var pageNameElement = document.getElementById('howitzer_stat_page_name');
            var pageNameElement = document.createElement('div');
            pageNameElement.setAttribute('class','how-stat-number');
            if (pageName == null) {
                pageNameElement.innerHTML = 'Unknown Page';
                statButton.addEventListener('click', function () {
                    alert("Page is Unknown, stats can't be loaded.")
                });
            } else {
                pageNameElement.innerHTML = pageName;
                pageNameElement.setAttribute('data-page-name', pageName);
                statButton.addEventListener('click', function () {
                    if (this.className.indexOf('non-active') >= 0) {
                        if (document.getElementById('how_stat_info').innerHTML == ''){
                            pageNameElement.innerHTML = 'Loading...';
                            xdr('GET', {pageName: pageName}, featuresByClassNameHandler, errorHandler);
                        } else {
                            document.getElementById('how_stat_popup').setAttribute('style','display: block;');
                            this.className = this.className.replace('non-active', 'active');
                        }
                    } else {
                        document.getElementById('how_stat_popup').setAttribute('style','display: none;');
                        this.className = this.className.replace('active', 'non-active');
                    }
                });
            }
            statButton.setAttribute('style', 'display: block;');
            statButton.appendChild(pageNameElement);
            statButtonsContainer.appendChild(statButton);
        });
    };


    var featuresByClassNameHandler = function(data){
        var template = document.getElementById('cucumberStat').innerHTML;
        var statDataElement = document.getElementById('how_stat_info');
        var featuresData = JSON.parse(data).features;
        if (featuresData == ''){
            statDataElement.innerHTML = 'There is no tests that include this page.';
        } else {
            statDataElement.innerHTML = _.template(template, {features: featuresData});
        }
        document.getElementById('how_stat_popup').setAttribute('style','display: block;');

//        var statButton = document.getElementById('howitzer_stat_btn');
//        statButton.className = statButton.className.replace('non-active', 'active');
//        var pageNameElement = document.getElementById('howitzer_stat_page_name');
//        pageNameElement.innerHTML = pageNameElement.getAttribute('data-page-name');
    };

    window.onload = function () {
        xdr('GET', {url: document.URL || window.location.href, title: document.title}, pageClassesByTitleAndUrlHandler, errorHandler);
    };
})();