using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using PetCenterModels.DBTables;
using PetCenterModels.Requests;
using PetCenterModels.SearchObjects;
using PetCenterServices.Interfaces;
using System.Security.Claims;


namespace PetCenterAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UserController : ControllerTemplate<User,UserSearchObject,UserRequestDTO,UserResponseDTO,IUserService>
    {

        public UserController(IUserService s):base(s) { }

       


       


    }

}
