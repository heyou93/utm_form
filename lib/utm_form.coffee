class UtmForm
  constructor: (options = {}) ->
    @_utmParamsMap = {}
    @_utmParamsMap.utm_source   = options.utm_source_field || 'USOURCE'
    @_utmParamsMap.utm_medium   = options.utm_medium_field || 'UMEDIUM'
    @_utmParamsMap.utm_campaign = options.utm_campaign_field || 'UCAMPAIGN'
    @_utmParamsMap.utm_content  = options.utm_content_field || 'UCONTENT'
    @_utmParamsMap.utm_term     = options.utm_term_field || 'UTERM'

    @_additionalParamsMap       = options.additional_params_map || {}

    @_initialReferrerField      = options.initial_referrer_field || 'IREFERRER'
    @_lastReferrerField         = options.last_referrer_field || 'LREFERRER'
    @_initialLandingPageField   = options.initial_landing_page_field || 'ILANDPAGE'
    @_visitsField               = options.visits_field || 'VISITS'

    # Options:
    # "none": Don't add any fields to any form
    # "first": Add UTM and other fields to only first form on the page
    # "all": (Default) Add UTM and other fields to all forms on the page
    @_addToForm                 = options.add_to_form || 'all';

    # Option to configure the form query selector to further restrict form
    # decoration, e.g. 'form[action="/sign_up"]'
    @_formQuerySelector         = options.form_query_selector || 'form';

    @utmCookie = new UtmCookie({
      domain: options.domain,
      sessionLength: options.sessionLength,
      cookieExpiryDays: options.cookieExpiryDays,
      additionalParams: Object.getOwnPropertyNames(@_additionalParamsMap) })

    @addAllFields()

  addAllFields: ->
    allForms = document.querySelectorAll(@_formQuerySelector)
    if @_addToForm == 'none'
      len = 0
    else if @_addToForm == 'first'
      len = Math.min 1, allForms.length
    else
      len = allForms.length

    i = 0
    while i < len
      @addAllFieldsToForm allForms[i]
      i++

    return

  addAllFieldsToForm: (form) ->
    if form && !form._utm_tagged
      form._utm_tagged = true

      for param, fieldName of @_utmParamsMap
        @addFormElem form, fieldName, @utmCookie.readCookie(param)

      for param, fieldName of @_additionalParamsMap
        @addFormElem form, fieldName, @utmCookie.readCookie(param)

      @addFormElem form, @_initialReferrerField, @utmCookie.initialReferrer()
      @addFormElem form, @_lastReferrerField, @utmCookie.lastReferrer()
      @addFormElem form, @_initialLandingPageField, @utmCookie.initialLandingPageUrl()
      @addFormElem form, @_visitsField, @utmCookie.visits()

    return

  addFormElem: (form, fieldName, fieldValue) ->
    @insertAfter @getFieldEl(fieldName, fieldValue), form.lastChild

    return

  # NOTE: This should be called for each form element or since it
  # attaches itself to the first form
  getFieldEl: (fieldName, fieldValue) ->
    fieldEl = document.createElement('input')
    fieldEl.type = "hidden"
    fieldEl.name = fieldName
    fieldEl.value = fieldValue
    fieldEl

  insertAfter: (newNode, referenceNode) ->
    referenceNode.parentNode.insertBefore(newNode, referenceNode.nextSibling)

_uf = window._uf || {}
window.UtmForm = new UtmForm _uf
