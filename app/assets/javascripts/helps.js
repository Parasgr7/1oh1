$(document).on('turbolinks:load', function() {
    var helpSections = ["communication","how","explorer","guide","legal","availabilty","account","privacypolicy","useragreement","cookiespolicy","professionalpolicy","refundpolicy"];
    var urlParams = new URLSearchParams(window.location.search);
    var activeSectionName = urlParams.get('section');

    $('.optionHelp').click(function(){
        console.log( $( this ).attr('id') )
        showSection($( this ).attr('id'))
    })

    if (activeSectionName === 'communication') {
        $('#communication').click()
    }

        function removeActive(){
            helpSections.forEach(section=>{
                $( "#"+section ).removeClass("active-link");
            });
        }
        function hideSections(){
            helpSections.forEach(section=>{
                $( "#section-"+section ).addClass("d-none");
            });
        }
    // ​
    function activateHelpLink(section){
        removeActive();
        $( "#"+section ).addClass("active-link");
    }
    // ​
    function activateHelpSection(section){
        if (section == "privacypolicy" || section == "useragreement" || section == "cookiespolicy" || section == "professionalpolicy" || section == "refundpolicy") {
            hideSections();
            $( "#section-legal" ).removeClass("d-none");
            $( "#legal" ).addClass("active-link");
        }else {
            hideSections();
        }
        $( "#section-"+section ).removeClass("d-none");
    }
    // ​
    function showSection(section){
        activateHelpLink(section);
        activateHelpSection(section);
    }


})
