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
    var pageClassesByTitleAndUrl;
    var pageClassesByTitleAndUrlHandler = function(data){
        pageClassesByTitleAndUrl = JSON.parse(data).page;
    };
    var featuresByClassName;
    var featuresByClassNameHandler = function(data){
        featuresByClassName = JSON.parse(data).features;
    };

    xdr('GET', {"url": document.url, "title": document.title}, pageClassesByTitleAndUrlHandler, errorHandler);
    xdr('GET', {"pageName": pageClassesByTitleAndUrl[0]}, featuresByClassNameHandler, errorHandler);

    var pagesDiv; //main stats container
    var popupDiv; //popup container

    // event listener to open and close popup
    function popupHandler() {
        if (popupDiv.style.display == 'none') {
            popupDiv.setAttribute('style','display: block');
            this.setAttribute('class', 'stat-button active');
        } else {
            popupDiv.setAttribute('style','display: none');
            this.setAttribute('class', 'stat-button non-active');
        }
    }
    // template creating
    window.onload = function () {
        pagesDiv = document.getElementById('stat-result');

        var activeClassButton = document.createElement('div');
        activeClassButton.setAttribute('class', 'stat-button non-active');

        var classNameSpan = document.createElement('span');
        classNameSpan.setAttribute('class', 'stat-number');
        if (pageClassesByTitleAndUrl[0] == null) {
            classNameSpan.innerHTML = 'Unknown Page';
            activeClassButton.addEventListener('click', function () {
                alert("Page is Unknown, stats can't be loaded.")
            });
        } else {
            classNameSpan.innerHTML = pageClassesByTitleAndUrl[0];
            activeClassButton.addEventListener('click', popupHandler);
        }
        activeClassButton.appendChild(classNameSpan);
        pagesDiv.appendChild(activeClassButton);

        var scriptTag = document.getElementById('cucumberStat');
        popupDiv = document.getElementById('stat-popup');

        var target = document.createElement('div');
        target.setAttribute('id', 'stat-info');

        target.innerHTML = _.template(scriptTag.innerHTML, {features: featuresByClassName});

        popupDiv.appendChild(target);
        pagesDiv.appendChild(popupDiv);
        popupDiv.setAttribute('style', 'display: none');
    };
})();