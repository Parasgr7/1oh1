document.addEventListener('turbolinks:load', event => {
   if (typeof gtag === 'function') {
     gtag('config', 'GA_TRACKING_ID', {
       'page_location': event.data.url
     });
   }
});
