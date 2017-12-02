using System.Linq;
using System.Web.Mvc;
using System.Web.UI;
using Nop.Core;
using Nop.Core.Infrastructure;

namespace Nop.Web.Framework.UI.Captcha
{
    public class GRecaptchaControl
    {
        private const string RECAPTCHA_API_URL_HTTP_VERSION1 = "http://www.google.com/recaptcha/api/challenge?k={0}";
        private const string RECAPTCHA_API_URL_HTTPS_VERSION1 = "https://www.google.com/recaptcha/api/challenge?k={0}";
        private const string RECAPTCHA_API_URL_VERSION2 = "https://www.google.com/recaptcha/api.js?onload=onloadCallback&render=explicit";

        public string Id { get; set; }
        public string Theme { get; set; }
        public string PublicKey { get; set; }
        public string Language { get; set; }

        //private readonly ReCaptchaVersion _version;

        public GRecaptchaControl()
        {
            
        }

        public void RenderControl(HtmlTextWriter writer)
        {
            SetTheme();


            var scriptCallbackTag = new TagBuilder("script");
            scriptCallbackTag.Attributes.Add("type", "text/javascript");
            scriptCallbackTag.InnerHtml = string.Format("var onloadCallback = function() {{grecaptcha.render('{0}', {{'sitekey' : '{1}', 'theme' : '{2}' }});}};", Id, PublicKey, Theme);
            writer.Write(scriptCallbackTag.ToString(TagRenderMode.Normal));

            var captchaTag = new TagBuilder("div");
            captchaTag.Attributes.Add("id", Id);
            writer.Write(captchaTag.ToString(TagRenderMode.Normal));

            var scriptLoadApiTag = new TagBuilder("script");
            scriptLoadApiTag.Attributes.Add("src", RECAPTCHA_API_URL_VERSION2 + (string.IsNullOrEmpty(Language) ? "" : string.Format("&hl={0}", Language)));
            scriptLoadApiTag.Attributes.Add("async", null);
            scriptLoadApiTag.Attributes.Add("defer", null);
            writer.Write(scriptLoadApiTag.ToString(TagRenderMode.Normal));
            
        }

        private void SetTheme()
        {
            var themes = new[] {"white", "blackglass", "red", "clean", "light", "dark"};


            switch (Theme.ToLower())
            {
                case "clean":
                case "red":
                case "white":
                    Theme = "light";
                    break;
                case "blackglass":
                    Theme = "dark";
                    break;
                default:
                    if (!themes.Contains(Theme.ToLower()))
                    {
                        Theme = "light";
                    }
                    break;
            }
            
        }
    }
}