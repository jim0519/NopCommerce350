using System.Collections.Generic;

namespace Nop.Web.Framework.UI.Captcha
{
    public class GReCaptchaResponse
    {
        public bool IsValid { get; set; }
        public List<string> ErrorCodes { get; set; }

        public GReCaptchaResponse()
        {
            ErrorCodes = new List<string>();
        }
    }
}