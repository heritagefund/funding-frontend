//Adapted from: https://github.com/alphagov/digitalmarketplace-govuk-frontend/blob/master/src/digitalmarketplace/helpers/cookie/cookie-functions.js

// used by the cookie banner component
const DEFAULT_COOKIE_CONSENT = {
    analytics: false
}

const COOKIE_CATEGORIES = {
    _hjClosedSurveyInvites: 'analytics',
    _hjDonePolls: 'analytics',
    _hjMinimizedPolls: 'analytics',
    _hjDoneTestersWidgets: 'analytics',
    _hjIncludedInSample: 'analytics',
    _hjid: 'analytics',
    _hjRecordingLastActivity: 'analytics',
    _hjTLDTest: 'analytics',
    _hjShownFeedbackMessage: 'analytics',
    _hjCachedUserAttributes: 'analytics',
    _hjLocalStorageTest: 'analytics',
    _hjUserAttributesHash: 'analytics'
}

export function getCookie (name) {
    var nameEQ = name + '='
    var cookies = document.cookie.split(';')
    for (var i = 0, len = cookies.length; i < len; i++) {
        var cookie = cookies[i]
        while (cookie.charAt(0) === ' ') {
            cookie = cookie.substring(1, cookie.length)
        }
        if (cookie.indexOf(nameEQ) === 0) {
            return decodeURIComponent(cookie.substring(nameEQ.length))
        }
    }
    return null
}
/*
Cookie methods
==============

Usage:

  Setting a cookie:
  setCookie('hobnob', 'tasty', { days: 30 })

  Reading a cookie:
  getCookie('hobnob')

  Deleting a cookie:
  Cookie('hobnob', null)
*/

export function Cookie (name, value, options) {
    if (typeof value !== 'undefined') {
        // If value is false or null, we are deleting the cookie, by expiry
        // being set to a day in the past
        if (value === false || value === null) {
            return setCookie(name, '', { days: -1 })
        } else {
            // Default expiry date of 30 days
            if (typeof options === 'undefined') {
                options = { days: 30 }
            }
            return setCookie(name, value, options)
        }
    } else {
        return getCookie(name)
    }
}

export function getConsentCookie () {
    var consentCookie = getCookie('nlhf_cookies_policy')
    var consentCookieObj

    if (consentCookie) {
        try {
            consentCookieObj = JSON.parse(consentCookie)
        } catch (err) {
            return null
        }

        if (typeof consentCookieObj !== 'object' && consentCookieObj !== null) {
            consentCookieObj = JSON.parse(consentCookieObj)
        }
    } else {
        return null
    }

    return consentCookieObj
}

export function setConsentCookie (options) {
    var cookieConsent = getConsentCookie()

    if (!cookieConsent) {
        cookieConsent = JSON.parse(JSON.stringify(DEFAULT_COOKIE_CONSENT))
    }

    for (var cookieType in options) {

        cookieConsent[cookieType] = options[cookieType]

        // Delete analytics cookies if options[cookieType] is set to false (meaning user hasn't agreed)
        if (!options[cookieType]) {
            for (var cookie in COOKIE_CATEGORIES) {
                // if this cookie is in the analytics cookie category list.
                if (COOKIE_CATEGORIES[cookie] === cookieType) {
                    // This deletes the cookie
                    Cookie(cookie, null)

                    // Get the cookie back
                    if (Cookie(cookie)) {
                        document.cookie = cookie + '=;expires=' + new Date() + ';domain=' + window.location.hostname.replace(/^www\./, '.') + ';path=/'
                    }
                }
            }
        }
    }

    setCookie('nlhf_cookies_policy', JSON.stringify(cookieConsent), { days: 365 })
}

export function checkConsentCookieCategory (cookieName, cookieCategory) {
    var currentConsentCookie = getConsentCookie()

    // If the consent cookie doesn't exist, but the cookie is in our known list, return true
    if (!currentConsentCookie && COOKIE_CATEGORIES[cookieName]) {
        return true
    }

    currentConsentCookie = getConsentCookie()
    

    // Sometimes currentConsentCookie is malformed in some of the tests, so we need to handle these
    try {
        return currentConsentCookie[cookieCategory]
    } catch (e) {
        console.error(e)
        return false
    }
}

export function checkConsentCookie (cookieName, cookieValue) {
    // If we're setting the consent cookie OR deleting a cookie, allow by default
    if (cookieName === 'nlhf_cookies_policy' || (cookieValue === null || cookieValue === false)) {
        return true
    }

    if (COOKIE_CATEGORIES[cookieName]) {
        var cookieCategory = COOKIE_CATEGORIES[cookieName]

        return checkConsentCookieCategory(cookieName, cookieCategory)
    } else {
        // Deny the cookie if it is not known to us
        return false
    }
}

// Usage :
// Setting a cookie:
// Cookie('hobnob', 'tasty', { days: 30 })

export function setCookie (name, value, options) {
    
    if (checkConsentCookie(name, value)) {
        
        if (typeof options === 'undefined') {
            options = {}
        }
        var cookieString = name + '=' + value + '; path=/'
        
        if (options.days) {
            var date = new Date()
            date.setTime(date.getTime() + (options.days * 24 * 60 * 60 * 1000))
            cookieString = cookieString + '; expires=' + date.toGMTString()
        }

        if (document.location.protocol === 'https:') {
            cookieString = cookieString + '; Secure'
        }

        document.cookie = cookieString

    }
}